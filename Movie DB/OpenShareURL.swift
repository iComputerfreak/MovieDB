//
//  OpenShareURL.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

struct OpenShareURLModifier: ViewModifier {
    @State private var showingMediaDetail = false
    @State private var presentedTMDBMediaType: MediaType?
    @State private var presentedTMDBID: Int?
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingMediaDetail, onDismiss: {
                self.presentedTMDBID = nil
                self.presentedTMDBMediaType = nil
            }, content: {
                ShareDetailView(presentedTMDBID: $presentedTMDBID, presentedTMDBMediaType: $presentedTMDBMediaType)
            })
            .onOpenURL { url in
                Logger.scenes.info("Opening URL \(url.absoluteString)...")
                // Get URL components from the incoming user activity.
                guard
                    let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
                else {
                    return
                }
                
                // Check for specific URL components that you need.
                guard
                    let path = components.path
                else {
                    Logger.scenes.error("The universal link does not contain a path: \(url.path(), privacy: .private)")
                    return
                }
                print("path = \(path)")
                
                // For now, we only allow paths in the form of "/(movie|tv)/{tmdbID}"
                let pathComponents = path.components(separatedBy: "/").dropFirst()
                guard
                    pathComponents.count == 2,
                    let mediaType = MediaType(rawValue: pathComponents.first!),
                    let tmdbID = Int(pathComponents.last!)
                else {
                    Logger.scenes.error(
                        "The universal link has invalid path components: \(url.path(), privacy: .private)"
                    )
                    return
                }
                DispatchQueue.main.async {
                    // Present the sheet
                    self.presentedTMDBMediaType = mediaType
                    self.presentedTMDBID = tmdbID
                    self.showingMediaDetail = true
                }
            }
    }
}

struct ShareDetailView: View {
    @Binding var presentedTMDBID: Int?
    @Binding var presentedTMDBMediaType: MediaType?
    
    var body: some View {
        // FIX: For some reason, using a NavigationStack here makes the MediaLookupDetail view load indefinitely.
        // NavigationStack {
        if let presentedTMDBID, let presentedTMDBMediaType {
            MediaLookupDetail(tmdbID: presentedTMDBID, mediaType: presentedTMDBMediaType, showingDismissButton: true)
        } else {
            Text(Strings.ShareDetail.errorLoadingMedia)
                .onAppear {
                    Logger.scenes.error(
                        // swiftlint:disable:next line_length
                        "Error displaying media with ID \(presentedTMDBID?.description ?? "nil") and type '\(presentedTMDBMediaType?.rawValue ?? "nil")'."
                    )
                }
        }
        // }
    }
}

extension View {
    func openShareURLModifier() -> some View {
        self.modifier(OpenShareURLModifier())
    }
}
