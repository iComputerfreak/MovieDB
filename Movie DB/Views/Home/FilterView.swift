//
//  FilterView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    
    @State private var mediaType: MediaType?
    /// Translates integer values from and to the `mediaType` property
    private var mediaTypeProxy: Binding<Int> {
        Binding<Int>(get: {
            if let type = self.mediaType {
                return type == .movie ? 0 : 1
            }
            return -1
        }, set: { type in
            if type == 0 {
                self.mediaType = .movie
            } else if type == 1 {
                self.mediaType = .show
            } else {
                self.mediaType = nil
            }
        })
    }
        
    init() {
        // Load all filter settings from the user defaults
        let defaults = UserDefaults.standard
        self._mediaType = State<MediaType?>(wrappedValue: defaults.object(forKey: Keys.mediaType) as? MediaType)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section/*(header: Text("Filter Options"))*/ {
                Picker("Media Type", selection: mediaTypeProxy) {
                    Text("Both")
                        .tag(-1)
                    Text("Movie")
                        .tag(0)
                    Text("Show")
                        .tag(1)
                }
                    Toggle(isOn: .constant(true), label: Text("Show only 'Not Watched'").closure())
                }
            }
            .navigationBarTitle("Filter Options")
        }
    }
    
    struct Keys {
        static let mediaType = "mediaType"
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
