//
//  LongTextView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a view that displays a preview of a longer text with the option to show the full text in a new view
struct LongTextView: View {
    static let lineLimit = 3
    
    var headline: String
    var text: String
    
    /// Creates a new view that displays a preview of the given text (3 lines).
    /// Provides the option to show the full text in a new view.
    /// - Parameters:
    ///   - headline: The headline of the new full text view
    ///   - text: The full text
    init(
        _ text: String,
        headline: String
    ) {
        self.headline = headline
        self.text = text
    }

    var body: some View {
        NavigationLink {
            ContentView(text: text)
                .navigationTitle(headline)
        } label: {
            Text(text)
                .lineLimit(Self.lineLimit)
                .headline(headline)
        }
    }
    
    struct ContentView: View {
        let text: String
        
        var body: some View {
            HStack {
                VStack(alignment: .center) {
                    Text(text)
                        .lineLimit(nil)
                        .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    LongTextView("A very long text", headline: "Description")
}
