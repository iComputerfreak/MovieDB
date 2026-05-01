// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import CoreData
import Foundation
import OSLog

struct ExportData {
    let filename: String
    let data: Data
}

struct SettingsViewModel {
    var isLoading = false
    var loadingText: String?
    var languageChanged = false
    var regionChanged = false
    var isShowingProInfo = false
    var isShowingReloadCompleteNotification = false
    var importLogShowing = false
    var importLogger: TagImporter.BasicLogger?
    var exportedData: ExportData?

    enum ExportFailure: Error {
        case failed(AnalyticsImportExportOperation, AnalyticsImportExportStage)
    }

    mutating func beginLoading(_ text: String) {
        self.isLoading = true
        self.loadingText = text
    }
    
    mutating func stopLoading() {
        self.isLoading = false
        self.loadingText = nil
    }

    func export(
        filename: String,
        operation: AnalyticsImportExportOperation,
        content: @escaping (NSManagedObjectContext) throws -> Data
    ) async -> ExportData? {
        Logger.importExport.debug("Exporting \(filename, privacy: .public)...")

        return await PersistenceController.shared.container.performBackgroundTask { context -> ExportData? in
            context.type = .backgroundContext
            do {
                // Get the content to export
                let exportData = try content(context)
                return ExportData(filename: filename, data: exportData)
            } catch {
                let failure: ExportFailure
                if let exportFailure = error as? ExportFailure {
                    failure = exportFailure
                } else {
                    failure = .failed(operation, .backgroundTask)
                }
                if case let .failed(operation, stage) = failure {
                    AnalyticsService.shared.track(.importExportFailed(operation: operation, stage: stage))
                }
                Logger.importExport.error("Error writing export file: \(error, privacy: .public)")
                DispatchQueue.main.async {
                    AlertHandler.showSimpleAlert(
                        title: Strings.Settings.Alert.genericExportErrorTitle,
                        message: Strings.Settings.Alert.genericExportErrorMessage
                    )
                }
                return nil
            }
        }
    }
}
