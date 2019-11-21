//
//  BasicTextView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct BasicTextView: View {
    
    var headline: String
    var text: String
    
    init(_ headline: String, text: String) {
        self.headline = headline
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(headline)
                .font(.caption)
            Text(text)
                .lineLimit(nil)
        }
    }
}

struct BasicTextView_Previews: PreviewProvider {
    static var previews: some View {
        BasicTextView("Headline", text: "Text")
    }
}
