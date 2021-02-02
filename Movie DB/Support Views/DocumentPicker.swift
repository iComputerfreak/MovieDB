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

final class DocumentPicker: NSObject, UIViewControllerRepresentable {
    
    var urlToExport: URL?
    var onSelect: (URL) -> ()
    var onCancel: (() -> ())?
    
    init(urlToExport: URL, onSelect: @escaping (URL) -> (), onCancel: (() -> ())?) {
        self.urlToExport = urlToExport
        self.onSelect = onSelect
        self.onCancel = onCancel
    }
    
    init(onSelect: @escaping (URL) -> (), onCancel: (() -> ())?) {
        self.urlToExport = nil
        self.onSelect = onSelect
        self.onCancel = onCancel
    }
    
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
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
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
