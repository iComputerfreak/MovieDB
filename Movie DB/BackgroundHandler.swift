// Copyright © 2023 Jonas Frey. All rights reserved.

import BackgroundTasks
import Analytics
import Foundation
import os.log
import UIKit

class BackgroundHandler {
    static let bgTaskID = "de.JonasFrey.Movie-DB.updateLibrary"
    // Run the background task every day
    static let bgTaskInterval: TimeInterval = .day
    
    init() {}

    private enum DebugKey {
        static let lastRunTime = "debug_lastBGFetchTime"
        static let lastCancelled = "debug_lastBGFetchCancelled"
        static let lastRescheduleResult = "debug_lastBGFetchRescheduleResult"
        static let lastResult = "debug_lastBGFetchResult"
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
            let didSchedule = await scheduleBackgroundFetch()
            writeDebugRescheduleResult(didSchedule)
        }
    }
    
    /// Schedules a background fetch to be executed ``bgTaskInterval`` from now.
    /// If there is already a background fetch scheduled, re-scheduling will be skipped.
    private func scheduleBackgroundFetch() async -> Bool {
        let pendingTasks = await BGTaskScheduler.shared.pendingTaskRequests()
        // Only schedule this task if it is not already pending.
        if pendingTasks.contains(where: { $0.identifier == Self.bgTaskID }) {
            return true
        }

        let request = BGProcessingTaskRequest(identifier: Self.bgTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: Self.bgTaskInterval)
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.background.info("Successfully scheduled background processing task request.")
            return true
        } catch {
            Logger.background.error("Could not schedule app processing task: \(error, privacy: .public)")
            return false
        }
    }
    
    /// Executes the background task and re-schedules it
    private func executeBackgroundProcessingTask(bgTask: BGTask) {
        writeDebugRunTime(.now)
        writeDebugCancelled(false)

        // MARK: Re-schedule
        Task {
            let didSchedule = await scheduleBackgroundFetch()
            writeDebugRescheduleResult(didSchedule)
        }

        // MARK: Create Operation
        let operation = Task(priority: .high) {
            do {
                Logger.background.info("Updating Library from background task...")
                let updatedMediaCount = try await MediaLibrary.shared.reloadAll(fromBackground: true)
                Logger.background.info("Reloaded \(updatedMediaCount) media objects from background task.")
                writeDebugResult(true)
                AnalyticsService.shared.track(.backgroundFetch(result: .success, cancelled: false, updatedMediaCount: updatedMediaCount))
                bgTask.setTaskCompleted(success: true)
            } catch {
                let wasCancelled = error is CancellationError || Task.isCancelled
                Logger.background.error("Error executing background task: \(error, privacy: .public)")
                writeDebugCancelled(wasCancelled)
                writeDebugResult(false)
                AnalyticsService.shared.track(.backgroundFetch(result: .failure, cancelled: wasCancelled, updatedMediaCount: 0))
                bgTask.setTaskCompleted(success: false)
            }
        }
        // The operation will be started automatically
        
        // MARK: Expiration Handler
        bgTask.expirationHandler = {
            Logger.background.info("Cancelling background task...")
            self.writeDebugCancelled(true)
            operation.cancel()
        }
    }

    private func writeDebugRunTime(_ date: Date) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: DebugKey.lastRunTime)
    }

    private func writeDebugCancelled(_ cancelled: Bool) {
        UserDefaults.standard.set(cancelled, forKey: DebugKey.lastCancelled)
    }

    private func writeDebugRescheduleResult(_ result: Bool) {
        UserDefaults.standard.set(result, forKey: DebugKey.lastRescheduleResult)
    }

    private func writeDebugResult(_ result: Bool) {
        UserDefaults.standard.set(result, forKey: DebugKey.lastResult)
    }
}
