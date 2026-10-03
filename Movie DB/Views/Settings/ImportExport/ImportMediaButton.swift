// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData
import os.log
import SwiftUI
import Analytics

struct ImportMediaButton: View {
    @Binding var config: SettingsViewModel
    @State private var isImportingMedia = false
    @State private var isConfirmingImport = false
    @State private var error: (any Error)?
    @State private var pendingImportContext: NSManagedObjectContext?
    @State private var pendingImportStartedAt: Date?
    @State private var pendingImportCount = 0
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext

    private let storeManager: StoreManager = .shared

    var body: some View {
        Button {
            isImportingMedia = true
        } label: {
            SettingsActionLabel(
                title: Strings.Settings.importMediaLabel,
                systemImage: "square.and.arrow.down.fill",
                tint: .green
            )
        }
        .fileImporter(isPresented: $isImportingMedia, allowedContentTypes: [.commaSeparatedText]) { result in
            do {
                let url = try result.get()
                self.importMedia(url: url)
            } catch {
                // Error picking file to import. No need to display an error, as the user is probably aware?
                Logger.importExport.error("Error picking import file: \(error, privacy: .public)")
            }
        }
        .alert(Strings.Settings.Alert.importMediaConfirmTitle, isPresented: $isConfirmingImport) {
            Button(
                Strings.Settings.Alert.importMediaConfirmButtonUndo,
                role: .destructive,
                action: undoPendingImport
            )
            Button(Strings.Generic.alertButtonOk, action: completePendingImport)
        } message: {
            Text(Strings.Settings.Alert.importMediaConfirmMessage(pendingImportCount))
        }
        .errorAlert(error: $error)
    }
    
    // swiftlint:disable:next function_body_length
    func importMedia(url: URL) {
        let importStartedAt = Date()

        if !storeManager.hasPurchasedPro {
            let mediaCount = MediaLibrary.shared.mediaCount() ?? 0
            guard mediaCount < JFLiterals.nonProMediaLimit else {
                config.isShowingProInfo = true
                return
            }
        }
        // Initialize the logger
        self.config.importLogger = .init()
        ImportExportSection.import(isLoading: $config.isLoading, onError: { error in
            self.error = error
        }) { importContext in
            // Import using CSVImporter
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportError.noPermissions
            }
            let importer = try CSVImporter(url: url)
            url.stopAccessingSecurityScopedResource()
            Logger.importExport.debug("Successfully read CSV file. Trying to import into library...")
            
            let medias: [Media]! // swiftlint:disable:this implicitly_unwrapped_optional
            do {
                medias = try await importer.decodeMediaObjects(importContext: importContext) { progress in
                    self.config.loadingText = Strings.Settings.loadingTextMediaImport(progress, importer.rowCount)
                } log: { message in
                    // TODO: Replace with other logger when reworking import view
                    // TODO: Maybe we can stream a specific OSLog logger to a buffer and display it?
                    self.config.importLogger?.log(message, level: .none)
                }
            } catch {
                DispatchQueue.main.async {
                    self.config.importLogShowing = true
                }
                AnalyticsService.shared.track(.importExportFailed(operation: .mediaImport, stage: .importProcessing))
                // Rethrow
                throw error
            }
            
            await MainActor.run {
                self.config.isLoading = false
                self.config.loadingText = nil
                self.pendingImportContext = importContext
                self.pendingImportStartedAt = importStartedAt
                self.pendingImportCount = medias.count
                self.isConfirmingImport = true
            }
        }
    }

    /// Discards objects created by the pending import.
    private func undoPendingImport() {
        pendingImportContext?.reset()
        config.importLogger?.info("Undoing import. All imported objects removed.")
        AnalyticsService.shared.track(
            .mediaImportAborted(
                importCountBucket: .bucket(for: pendingImportCount),
                durationSeconds: pendingImportDurationSeconds,
                errorCount: config.importLogger?.count(of: .error) ?? 0
            )
        )
        config.importLogShowing = true
        clearPendingImport()
    }

    /// Saves objects created by the pending import.
    private func completePendingImport() {
        guard let importContext = pendingImportContext else { return }
        let importCount = pendingImportCount
        let durationSeconds = pendingImportDurationSeconds
        let errorCount = config.importLogger?.count(of: .error) ?? 0
        clearPendingImport()

        Task(priority: .userInitiated) {
            await PersistenceController.saveContext(importContext)
            await PersistenceController.saveContext(PersistenceController.viewContext)
            AnalyticsService.shared.track(
                .mediaImported(
                    importCountBucket: .bucket(for: importCount),
                    durationSeconds: durationSeconds,
                    errorCount: errorCount
                )
            )
            config.importLogger?.info("Import complete.")
            config.importLogShowing = true
        }
    }

    /// Elapsed seconds for the pending import.
    private var pendingImportDurationSeconds: Int {
        Int(Date().timeIntervalSince(pendingImportStartedAt ?? .now).rounded())
    }

    /// Clears temporary import confirmation state.
    private func clearPendingImport() {
        pendingImportContext = nil
        pendingImportStartedAt = nil
        pendingImportCount = 0
    }
}

#Preview {
    ImportMediaButton(config: .constant(.init()))
}
