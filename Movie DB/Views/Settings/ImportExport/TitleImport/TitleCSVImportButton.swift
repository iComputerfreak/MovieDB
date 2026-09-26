// Copyright © 2026 Jonas Frey. All rights reserved.

import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct TitleCSVImportButton: View {
    @Binding var config: SettingsViewModel
    @State private var isPickingFile = false
    @State private var workflow: TitleImportWorkflow?

    var body: some View {
        Button(action: beginFileSelection) {
            SettingsActionLabel(
                title: Strings.TitleImport.settingsAction,
                systemImage: "text.magnifyingglass",
                tint: .teal
            )
        }
        .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [.commaSeparatedText]) { result in
            do {
                workflow = TitleImportWorkflow(fileURL: try result.get())
            } catch {
                Logger.importExport.error("Error picking title import file: \(error, privacy: .public)")
            }
        }
        .fullScreenCover(item: $workflow) { workflow in
            TitleImportFlowView(workflow: workflow)
        }
    }

    private func beginFileSelection() {
        if !StoreManager.shared.hasPurchasedPro,
           (MediaLibrary.shared.mediaCount() ?? 0) >= JFLiterals.nonProMediaLimit {
            config.isShowingProInfo = true
        } else {
            isPickingFile = true
        }
    }
}
