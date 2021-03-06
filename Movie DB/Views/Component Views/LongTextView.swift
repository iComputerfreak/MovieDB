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
    
    var headline: Text
    var text: String
    
    /// Creates a new view that displays a preview of the given text (3 lines).
    /// Provides the option to show the full text in a new view.
    /// - Parameters:
    ///   - headline: The headline of the new full text view
    ///   - text: The full text
    init(_ text: String, headlineKey: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
        self.headline = Text(headlineKey, tableName: tableName, bundle: bundle, comment: comment)
        self.text = text
    }
    
    var body: some View {
            NavigationLink(destination: preview) {
                Text(text)
                    .lineLimit(3)
            }
    }
    
    private var preview: some View {
        VStack(alignment: .center) {
            Text(text)
                .lineLimit(nil)
                .padding()
            Spacer()
        }
        .navigationBarTitle(headline)
    }
}

struct LongTextView_Previews: PreviewProvider {
    static var previews: some View {
        LongTextView("A very long text", headlineKey: "Description")
    }
}
