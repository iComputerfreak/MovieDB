//
//  ShareSheet.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.03.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import SwiftUI
import UIKit

// TODO: Remove
struct ShareSheet: UIViewControllerRepresentable {
    
    let activityViewController = ActivityViewController()
    
    func makeUIViewController(context: Context) -> ActivityViewController {
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {}
    
    /// Shares the file at the given URL and then deletes it
    func shareFile(url: URL) {
        print("Sharing file at URL \(url)")
        activityViewController.url = url
        activityViewController.shareFile()
    }
}

class ActivityViewController: UIViewController {
    
    var url: URL!
    
    /// Shares the file at the given URL and then deletes it
    func shareFile() {
        let vc = UIActivityViewController(activityItems: [url!], applicationActivities: [])
        DispatchQueue.main.async {
            self.present(vc, animated: true)
            vc.popoverPresentationController?.sourceView = self.view
        }
    }
    
}
