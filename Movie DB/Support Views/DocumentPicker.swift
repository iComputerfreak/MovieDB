//
//  DocumentPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.03.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit
import SwiftUI

// TODO: Make async using a continuation
final class DocumentPicker: NSObject, UIViewControllerRepresentable {
    
    var urlToExport: URL?
    var onSelect: (URL) -> Void
    var onCancel: (() -> Void)?
    
    lazy var viewController: UIDocumentPickerViewController = {
        let controller: UIDocumentPickerViewController!
        if let url = self.urlToExport {
            // Save file
            controller = UIDocumentPickerViewController(forExporting: [url])
        } else {
            // Open file
            controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text], asCopy: true)
        }
        controller.modalPresentationStyle = .formSheet
        controller.delegate = self
        return controller
    }()
    
    init(urlToExport: URL, onSelect: @escaping (URL) -> Void, onCancel: (() -> Void)?) {
        self.urlToExport = urlToExport
        self.onSelect = onSelect
        self.onCancel = onCancel
    }
    
    init(onSelect: @escaping (URL) -> Void, onCancel: (() -> Void)?) {
        self.urlToExport = nil
        self.onSelect = onSelect
        self.onCancel = onCancel
    }
    
    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: UIViewControllerRepresentableContext<DocumentPicker>
    ) {}
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        viewController.delegate = self
        return viewController
    }
}

extension DocumentPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Selected a document: \(urls[0])")
        onSelect(urls[0])
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker cancelled.")
        onCancel?()
    }
}
