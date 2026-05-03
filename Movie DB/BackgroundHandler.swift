// Copyright © 2023 Jonas Frey. All rights reserved.

import BackgroundTasks
import Analytics
import Foundation
import os.log
import UIKit

class BackgroundHandler {
    static let bgTaskID = "de.JonasFrey.Movie-DB.updateLibrary"
    static let defaultBackgroundUpdateInterval: TimeInterval = .day

    enum DebugExecutionResult: String, Codable {
        case success
        case failure
        case skippedFlagDisabled = "skipped_flag_disabled"
        case unknown
    }

    enum DebugRescheduleResult: String, Codable {
        case scheduled
        case disabledByFlag = "disabled_by_flag"
        case failed
        case unknown
    }

    struct DebugState: Codable {
        var lastRunTime: Date?
        var lastCancelled: Bool?
        var lastRescheduleResult: DebugRescheduleResult = .unknown
        var lastResult: DebugExecutionResult = .unknown
        var lastResolvedInterval: TimeInterval?
        var lastErrorDescription: String?
    }
    
    init() {}

    private enum DebugKey {
        static let state = "debug_backgroundFetchState"
    }

    static var currentBackgroundUpdateInterval: TimeInterval? {
        guard AnalyticsService.shared.isFeatureEnabled(.backgroundUpdates) else {
            return nil
        }

        return resolvedBackgroundUpdateInterval()
    }

    static var debugState: DebugState {
        get {
            guard
                let data = UserDefaults.standard.data(forKey: DebugKey.state),
                let state = try? JSONDecoder().decode(DebugState.self, from: data)
            else {
                return DebugState()
            }

            return state
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                Logger.background.error("Could not encode background fetch debug state.")
                return
            }

            UserDefaults.standard.set(data, forKey: DebugKey.state)
        }
    }

    /// Registers the background fetch task ID and schedules the recurring execution.
    func setupBackgroundFetch() {
        let result = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgTaskID,
            using: nil,
            launchHandler: executeBackgroundProcessingTask(bgTask:)
        )
        if !result {
            Logger.background.fault(
                "The background task could not be registered, because its identifier is missing from Info.plist"
            )
        }
        Task {
            _ = await refreshBackgroundFetch()
        }
    }

    @discardableResult
    func refreshBackgroundFetch() async -> Bool {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.bgTaskID)

        guard let interval = Self.currentBackgroundUpdateInterval else {
            Logger.background.info("Background updates disabled by feature flag.")
            var debugState = Self.debugState
            debugState.lastResolvedInterval = nil
            debugState.lastRescheduleResult = .disabledByFlag
            debugState.lastErrorDescription = nil
            Self.debugState = debugState
            return true
        }

        var debugState = Self.debugState
        debugState.lastResolvedInterval = interval
        Self.debugState = debugState
        return await scheduleBackgroundFetch(after: interval)
    }

    /// Schedules a background fetch to be executed after the passed interval.
    private func scheduleBackgroundFetch(after interval: TimeInterval) async -> Bool {
        let request = BGProcessingTaskRequest(identifier: Self.bgTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.background.info("Successfully scheduled background processing task request.")
            var debugState = Self.debugState
            debugState.lastRescheduleResult = .scheduled
            debugState.lastErrorDescription = nil
            Self.debugState = debugState
            return true
        } catch {
            Logger.background.error("Could not schedule app processing task: \(error, privacy: .public)")
            var debugState = Self.debugState
            debugState.lastRescheduleResult = .failed
            debugState.lastErrorDescription = String(describing: error)
            Self.debugState = debugState
            return false
        }
    }
    
    /// Executes the background task and re-schedules it
    private func executeBackgroundProcessingTask(bgTask: BGTask) {
        var debugState = Self.debugState
        debugState.lastRunTime = .now
        debugState.lastCancelled = false
        Self.debugState = debugState

        guard let interval = Self.currentBackgroundUpdateInterval else {
            Logger.background.info("Skipping background task because feature flag is disabled.")
            var debugState = Self.debugState
            debugState.lastResolvedInterval = nil
            debugState.lastResult = .skippedFlagDisabled
            debugState.lastErrorDescription = nil
            Self.debugState = debugState
            bgTask.setTaskCompleted(success: true)
            return
        }

        debugState = Self.debugState
        debugState.lastResolvedInterval = interval
        Self.debugState = debugState

        // MARK: Re-schedule
        Task {
            _ = await scheduleBackgroundFetch(after: interval)
        }

        // MARK: Create Operation
        let operation = Task(priority: .high) {
            do {
                Logger.background.info("Updating Library from background task...")
                let updatedMediaCount = try await MediaLibrary.shared.reloadAll(fromBackground: true)
                Logger.background.info("Reloaded \(updatedMediaCount) media objects from background task.")
                var debugState = Self.debugState
                debugState.lastResult = .success
                debugState.lastErrorDescription = nil
                Self.debugState = debugState
                AnalyticsService.shared.track(.backgroundFetch(result: .success, cancelled: false, updatedMediaCount: updatedMediaCount))
                bgTask.setTaskCompleted(success: true)
            } catch {
                let wasCancelled = error is CancellationError || Task.isCancelled
                Logger.background.error("Error executing background task: \(error, privacy: .public)")
                var debugState = Self.debugState
                debugState.lastCancelled = wasCancelled
                debugState.lastResult = .failure
                debugState.lastErrorDescription = String(describing: error)
                Self.debugState = debugState
                AnalyticsService.shared.track(.backgroundFetch(result: .failure, cancelled: wasCancelled, updatedMediaCount: 0))
                bgTask.setTaskCompleted(success: false)
            }
        }
        // The operation will be started automatically
        
        // MARK: Expiration Handler
        bgTask.expirationHandler = {
            Logger.background.info("Cancelling background task...")
            var debugState = Self.debugState
            debugState.lastCancelled = true
            Self.debugState = debugState
            operation.cancel()
        }
    }

    private static func resolvedBackgroundUpdateInterval() -> TimeInterval {
        let hours = AnalyticsService.shared.featureFlagPayload(.backgroundUpdates, as: Int.self)
            .map(Double.init)
            ?? AnalyticsService.shared.featureFlagPayload(.backgroundUpdates, as: Double.self)
            ?? AnalyticsService.shared.featureFlagPayload(.backgroundUpdates, as: String.self).flatMap(Double.init)

        guard let hours, hours > 0 else {
            return defaultBackgroundUpdateInterval
        }

        return hours * 60 * 60
    }
}
