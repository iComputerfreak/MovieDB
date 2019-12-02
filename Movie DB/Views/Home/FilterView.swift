//
//  FilterView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// The string representing a `nil` value in a `Picker`
fileprivate let nilString = "any"

struct FilterView: View {
    
    @State private var filterSettings = JFConfig.shared.filterSettings
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSettings.type?.rawValue ?? nilString
        }, set: { type in
            self.filterSettings.type = type.isNil ? nil : MediaType(rawValue: type)
        })
    }
        
    init() {}
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // MARK: Media Type
                    Picker("Media Type", selection: mediaTypeProxy) {
                        Text("Any")
                            .tag(nilString)
                        Text("Movie")
                            .tag(MediaType.movie.rawValue)
                        Text("Show")
                            .tag(MediaType.show.rawValue)
                    }
                    // MARK: Genres
                    FilterMultiPicker(selection: $filterSettings.genres, label: { $0.name }, values: Genre.allGenres, title: Text("Genres"))
                }
            }
            .navigationBarTitle("Filter Options")
        }
    }
}

fileprivate extension String {
    /// Whether this string is equal to the `nilString`
    var isNil: Bool { self == nilString }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
