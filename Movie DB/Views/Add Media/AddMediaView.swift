//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import Combine
import struct JFSwiftUI.LoadingView

struct AddMediaView: View {
    @State private var library: MediaLibrary = .shared
    @State private var isShowingProPopup = false
    @State private var isLoading = false
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                SearchResultsView { result in
                    Button {
                        Task(priority: .userInitiated) {
                            await self.addMedia(result)
                        }
                    } label: {
                        SearchResultRow(result: result)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .navigationTitle(Text("Add Media"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: { Text("Cancel") }))
            }
        }
        .popover(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }
    
    func addMedia(_ result: TMDBSearchResult) async {
        print("Selected \(result.title)")
        // Add the media object to the library
        do {
            try await library.addMedia(result, isLoading: $isLoading, isShowingProPopup: $isShowingProPopup)
        } catch {
            print("Error loading media: \(error)")
            await MainActor.run {
                AlertHandler.showSimpleAlert(
                    title: NSLocalizedString("Error"),
                    message: NSLocalizedString("Error loading media: \(error.localizedDescription)")
                )
                self.isLoading = false
            }
        }
        // Dismiss the AddMediaView
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct AddMediaView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .popover(isPresented: .constant(true)) {
                AddMediaView()
            }
    }
}
