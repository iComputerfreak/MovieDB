//
//  SearchResultView.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SearchResultView : View {
    
    var title: String
    var image: UIImage?
    var year: Int?
    var overview: String?
    var type: MediaType
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
    }
}

#if DEBUG
struct SearchResultView_Previews : PreviewProvider {
    static var previews: some View {
        Text("Not implemeted")
        //SearchResultView()
    }
}
#endif
