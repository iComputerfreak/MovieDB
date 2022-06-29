//
//  LookupView.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Combine
import JFSwiftUI
import SwiftUI

struct LookupView: View {
    @State private var isLoading = false
    @State private var isShowingProPopup = false
    
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
                .navigationTitle(Strings.TabView.lookupLabel)
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
