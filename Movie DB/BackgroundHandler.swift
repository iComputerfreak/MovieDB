//
//  BackgroundHandler.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import BackgroundTasks
import Foundation
import os.log
import UIKit

class BackgroundHandler {
    static let bgTaskID = "de.JonasFrey.Movie-DB.updateLibrary"
    static let bgTaskInterval: TimeInterval = 3 * .day
    
    init() {}
    
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
            await scheduleBackgroundFetch()
        }
    }
    
    /// Schedules a background fetch to be executed ``bgTaskInterval`` from now.
    /// If there is already a background fetch scheduled, re-scheduling will be skipped.
    private func scheduleBackgroundFetch() async {
        let pendingTasks = await BGTaskScheduler.shared.pendingTaskRequests()
        // Only schedule, if there is not already one scheduled
        guard pendingTasks.isEmpty else { return }

        let request = BGProcessingTaskRequest(identifier: Self.bgTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: Self.bgTaskInterval)
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.background.info("Successfully scheduled background processing task request.")
        } catch {
            Logger.background.error("Could not schedule app processing task: \(error, privacy: .public)")
        }
    }
    
    /// Executes the background task and re-schedules it
    private func executeBackgroundProcessingTask(bgTask: BGTask) {
        // MARK: Re-schedule
        Task {
            await scheduleBackgroundFetch()
        }

        // MARK: Create Operation
        let operation = Task(priority: .high) {
            do {
                Logger.background.info("Updating Library from background task...")
                try await MediaLibrary.shared.reloadAll(fromBackground: true)
                Logger.background.info("Reloaded all media objects.")
                bgTask.setTaskCompleted(success: true)
            } catch {
                Logger.background.error("Error executing background task: \(error, privacy: .public)")
                bgTask.setTaskCompleted(success: false)
            }
        }
        // The operation will be started automatically
        
        // MARK: Expiration Handler
        bgTask.expirationHandler = {
            Logger.background.info("Cancelling background task...")
            operation.cancel()
        }
    }
}
