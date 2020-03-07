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

struct DocumentPicker: UIViewControllerRepresentable {
    
    var callback: (URL) -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .import)
        controller.delegate = context.coordinator
        controller.modalPresentationStyle = .formSheet
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ pickerController: DocumentPicker) {
            self.parent = pickerController
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Selected a document: \(urls[0])")
            parent.callback(urls[0])
        }
        
        func documentPickerWasCancelled() {
            print("Picker cancelled.")
        }
    }
    
}
