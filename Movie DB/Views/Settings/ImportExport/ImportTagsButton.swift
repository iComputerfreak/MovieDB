// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import CoreData
import os.log
import SwiftUI

struct ImportTagsButton: View {
    @Binding var config: SettingsViewModel
    @State private var isImportingTags = false
    @State private var isConfirmingImport = false
    @State private var error: (any Error)?
    @State private var pendingImportContext: NSManagedObjectContext?
    @State private var pendingImportData: String?
    @State private var pendingImportStartedAt: Date?
    @State private var pendingImportCount = 0
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        Button {
            isImportingTags = true
        } label: {
            SettingsActionLabel(
                title: Strings.Settings.importTagsLabel,
                systemImage: "arrow.down.circle.fill",
                tint: .purple
            )
        }
        .fileImporter(isPresented: $isImportingTags, allowedContentTypes: [.plainText]) { result in
            do {
                let url = try result.get()
                self.importTags(url: url)
            } catch {
                Logger.importExport.error("Error importing tags: \(error, privacy: .public)")
            }
        }
        .alert(Strings.Settings.Alert.importTagsConfirmTitle, isPresented: $isConfirmingImport) {
            Button(Strings.Generic.alertButtonNo, role: .cancel, action: clearPendingImport)
            Button(Strings.Generic.alertButtonYes, action: completePendingImport)
        } message: {
            Text(Strings.Settings.Alert.importTagsConfirmMessage(pendingImportCount))
        }
        .errorAlert(error: $error)
    }
    
    func importTags(url: URL) {
        let importStartedAt = Date()
        // Initialize the logger
        self.config.importLogger = .init()
        ImportExportSection.import(isLoading: $config.isLoading, onError: { error in
            self.error = error
        }) { importContext in
            importContext.type = .backgroundContext
            
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportError.noPermissions
            }
            let importData = try String(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            Logger.importExport.debug("Successfully read tags file. Trying to import into library.")
            // Count the non-empty tags
            let count = importData.components(separatedBy: "\n").filter { !$0.isEmpty }.count
            
            await MainActor.run {
                self.config.isLoading = false
                self.pendingImportContext = importContext
                self.pendingImportData = importData
                self.pendingImportStartedAt = importStartedAt
                self.pendingImportCount = count
                self.isConfirmingImport = true
            }
        }
    }

    /// Imports tags after user confirmation.
    private func completePendingImport() {
        guard let importContext = pendingImportContext, let importData = pendingImportData else { return }
        let importCount = pendingImportCount
        let importStartedAt = pendingImportStartedAt ?? .now
        clearPendingImport()

        Task(priority: .userInitiated) {
            do {
                try await TagImporter.import(importData, into: importContext)
                await PersistenceController.saveContext(importContext)
                let durationSeconds = Int(Date().timeIntervalSince(importStartedAt).rounded())
                AnalyticsService.shared.track(
                    .tagsImported(
                        importCountBucket: .bucket(for: importCount),
                        durationSeconds: durationSeconds,
                        errorCount: 0
                    )
                )
            } catch {
                AnalyticsService.shared.track(.importExportFailed(operation: .tagsImport, stage: .importProcessing))
                Logger.importExport.error("Error importing tags: \(error, privacy: .public)")
                self.error = error
            }
        }
    }

    /// Clears temporary import confirmation state.
    private func clearPendingImport() {
        pendingImportContext = nil
        pendingImportData = nil
        pendingImportStartedAt = nil
        pendingImportCount = 0
    }
}

#Preview {
    ImportTagsButton(config: .constant(.init()))
}
