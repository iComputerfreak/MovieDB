//
//  LinkView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LinkView: View {
    
    var headline: String
    var text: String
    var link: String
    
    var body: some View {
        Button(action: {
            if let link = URL(string: self.link) {
                UIApplication.shared.open(link)
            }
        }, label: {
            Text(text)
        })
    }
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(headline: "Headline", text: "Text", link: "https://www.google.de")
    }
}
