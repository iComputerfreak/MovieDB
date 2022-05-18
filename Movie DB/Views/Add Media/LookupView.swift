//
//  LookupView.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import Combine
import JFSwiftUI

// TODO: Localize
struct LookupView: View {
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var isShowingProPopup = false
    @State private var cancellable: AnyCancellable?
    @State private var displayedMedia: Media?
    // The subject used to fire the searchText changed events
    private let searchTextChangedSubject = PassthroughSubject<String, Never>()
    
    @Environment(\.managedObjectContext) private var managedObjectContext
        
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                SearchResultsView { result in
                    NavigationLink {
                        MediaLookupDetail(tmdbID: result.id, mediaType: result.mediaType)
                    } label: {
                        SearchResultRow(result: result)
                    }
                }
                .navigationTitle(String(
                    localized: "tabView.lookup.label",
                    comment: "The label of the lookup tab of the main TabView"
                ))
            }
        }
        .popover(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }
}

struct LookupView_Previews: PreviewProvider {
    static var previews: some View {
        LookupView()
    }
}
