// Copyright © 2026 Jonas Frey. All rights reserved.

import BackgroundTasks
import Foundation

/// Coordinates one title-import operation across scheduler callbacks, Swift task cancellation, and completion.
@available(iOS 26.0, *)
final class TitleImportTaskCoordinator<Outcome: Sendable> {
    private let lock = NSLock()
    private let scheduler: BGTaskScheduler
    private let taskIdentifier: String
    private let cancellationOutcome: Outcome

    private var backgroundTask: BGContinuedProcessingTask?
    private var continuation: CheckedContinuation<Outcome, Never>?
    private var worker: Task<Void, Never>?
    private var didStart = false
    private var didFinish = false
    private var cancellationRequested = false

    /// Creates a coordinator for one scheduler request.
    /// - Parameters:
    ///   - taskIdentifier: The unique scheduler request identifier.
    ///   - cancellationOutcome: The outcome returned if cancellation occurs before work starts.
    ///   - scheduler: The scheduler used to cancel a queued request.
    init(
        taskIdentifier: String,
        cancellationOutcome: Outcome,
        scheduler: BGTaskScheduler = .shared
    ) {
        self.taskIdentifier = taskIdentifier
        self.scheduler = scheduler
        self.cancellationOutcome = cancellationOutcome
    }

    /// Stores the awaiting continuation or immediately returns when cancellation already completed the task.
    /// - Parameter continuation: The continuation awaiting the import result.
    /// - Returns: Whether setup should continue.
    func install(_ continuation: CheckedContinuation<Outcome, Never>) -> Bool {
        lock.lock()
        if didFinish {
            lock.unlock()
            continuation.resume(returning: cancellationOutcome)
            return false
        }
        self.continuation = continuation
        lock.unlock()
        return true
    }

    /// Submits the request unless cancellation already completed the import.
    /// - Parameter request: The continued-processing request to submit.
    /// - Throws: A scheduler submission error.
    func submit(_ request: BGContinuedProcessingTaskRequest) throws {
        lock.lock()
        let shouldSubmit = !didFinish
        lock.unlock()
        guard shouldSubmit else { return }

        try scheduler.submit(request)

        // Cancellation can race with submission, so remove a request submitted after cancellation won.
        lock.lock()
        let shouldCancel = didFinish
        lock.unlock()
        if shouldCancel {
            scheduler.cancel(taskRequestWithIdentifier: taskIdentifier)
        }
    }

    /// Starts the operation at most once and associates it with an optional continued-processing task.
    /// - Parameters:
    ///   - backgroundTask: The system task protecting the import, or `nil` for foreground fallback.
    ///   - operation: The asynchronous operation.
    func start(
        backgroundTask: BGContinuedProcessingTask?,
        operation: @escaping @Sendable () async -> Outcome
    ) {
        lock.lock()
        guard !didFinish, !didStart else {
            lock.unlock()
            backgroundTask?.setTaskCompleted(success: false)
            return
        }
        didStart = true
        self.backgroundTask = backgroundTask
        lock.unlock()

        let worker = Task {
            let result = await operation()
            finish(with: result)
        }

        lock.lock()
        self.worker = worker
        let shouldCancel = cancellationRequested || didFinish
        lock.unlock()

        if shouldCancel {
            worker.cancel()
        }
    }

    /// Requests cancellation and resolves immediately when queued work has not started.
    func cancel() {
        lock.lock()
        guard !didFinish else {
            lock.unlock()
            return
        }
        cancellationRequested = true
        let worker = worker
        let shouldFinishImmediately = !didStart
        let continuation = shouldFinishImmediately ? continuation : nil
        let backgroundTask = shouldFinishImmediately ? backgroundTask : nil
        if shouldFinishImmediately {
            didFinish = true
            self.continuation = nil
            self.backgroundTask = nil
        }
        lock.unlock()

        scheduler.cancel(taskRequestWithIdentifier: taskIdentifier)
        worker?.cancel()

        if shouldFinishImmediately {
            backgroundTask?.setTaskCompleted(success: false)
            continuation?.resume(returning: cancellationOutcome)
        }
    }

    /// Completes the scheduler task and resumes the caller exactly once.
    /// - Parameter outcome: The completed or partially completed operation outcome.
    private func finish(with outcome: Outcome) {
        lock.lock()
        guard !didFinish else {
            lock.unlock()
            return
        }
        didFinish = true
        let wasCancelled = cancellationRequested
        let continuation = continuation
        let backgroundTask = backgroundTask
        self.continuation = nil
        self.backgroundTask = nil
        worker = nil
        lock.unlock()

        backgroundTask?.setTaskCompleted(success: !wasCancelled)
        continuation?.resume(returning: outcome)
    }
}
