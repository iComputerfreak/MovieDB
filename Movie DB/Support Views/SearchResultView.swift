//
//  SearchResultView.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SearchResultView : View {
    
    // Typical poster ratio is 1.5 height to 1.0 width
    let thumbnailSize: CGSize = .init(width: 80.0 / 1.5, height: 80.0)
    
    var title: String
    var imagePath: String?
    @State var image: UIImage?
    var year: Int?
    var overview: String?
    var type: MediaType
    var isAdult: Bool?
    
    var yearString: String {
        guard let year = year else {
            return ""
        }
        return " (\(year))"
    }
    
    func didAppear() {
        guard let imagePath = self.imagePath else {
            return
        }
        JFUtils.getRequest(JFUtils.getTMDBImageURL(path: imagePath), parameters: [:]) { (data) in
            guard let data = data else {
                return
            }
            self.image = UIImage(data: data)
        }
    }
    
    var body: some View {
        HStack {
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height, alignment: .center)
            } else {
                if (self.type == MediaType.movie) {
                    Image(systemName: "film")
                        .resizable()
                        // FIXME: Aspect ratio does not fit right (tv and film should be smaller)
                        .aspectRatio(0.9, contentMode: .fit)
                        .padding(5)
                        .frame(width: thumbnailSize.width, height: thumbnailSize.height, alignment: .center)
                } else {
                    Image(systemName: "tv")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(5)
                        .frame(width: thumbnailSize.width, height: thumbnailSize.height, alignment: .center)
                }
            }
            VStack(alignment: .leading) {
                Text("\(title)")
                    .bold()
                HStack {
                    if isAdult != nil && isAdult! {
                        Image(systemName: "a.square")
                    }
                    Text(type == .movie ? "Movie" : "Series")
                        .italic()
                    Text(year != nil ? "(\(String(describing: year!)))" : "")
                }
            }
        }
        .onAppear(perform: self.didAppear)
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
