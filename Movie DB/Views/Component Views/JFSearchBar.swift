//
//  JFSearchBar.swift
//  Movie DB
//
//  Created by Jonas Frey on 19.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

/// A replicate of the iOS search bar without a Cancel button
struct JFSearchBar: View {
    @Binding var text: String
    let prompt: Text
    @FocusState private var isFocused: Bool
    
    var showingClearButton: Bool {
        isFocused && !text.isEmpty
    }
    
    var body: some View {
        HStack {
            TextField(text: $text) {
                prompt
                    .foregroundColor(.secondary)
            }
                .focused($isFocused)
                .padding(7)
                .padding(.horizontal, 25)
                .background(.searchBarBackground)
                .cornerRadius(8)
                .padding(.horizontal, 10)
        }
        .overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 16)
                }
                .opacity(showingClearButton ? 1 : 0)
                .animation(.snappy, value: showingClearButton)
            }
        )
        .padding(.horizontal, 6)
    }
}

#Preview {
    @State var text = ""
    
    return JFSearchBar(text: $text, prompt: Text(Strings.AddMedia.searchPrompt))
}
