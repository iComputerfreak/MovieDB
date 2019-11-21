//
//  LongTextView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LongTextView: View {
    
    var headline: String
    var text: String
    
    init(_ headline: String, text: String) {
        self.headline = headline
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
            Text(headline)
                .font(.caption)
            // FIXME: This should display as multiple lines, instead of one, currently bugged.
            NavigationLink(destination: preview) {
                Text(text)
                    .lineLimit(3)
            }
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
        LongTextView("Headline", text: "A very long text")
    }
}
