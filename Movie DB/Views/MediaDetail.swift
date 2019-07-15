//
//  MediaDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaDetail : View {
    
    @State var mediaObject: Media
    
    var body: some View {
        // Group is needed so swift can infer the return type
        Group {
            if (mediaObject.tmdbData == nil) {
                Text("Error loading information!")
            }
            
            // Unwrap the optional data
            mediaObject.tmdbData.map { data in
                List {
                    // Thumbnail and basic infos
                    HStack(alignment: .center) {
                        if mediaObject.thumbnail == nil {
                            // Placeholder image
                            // TODO: Fix size
                            Image(systemName: "film")
                                .padding()
                        }
                        mediaObject.thumbnail.map { thumbnail in
                            // FIXME: Padding gets ignored!
                            PresentationLink(destination:
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                            ) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: JFLiterals.thumbnailSize.width * 2, height: JFLiterals.thumbnailSize.height * 2, alignment: .leading)
                                    .padding()
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(data.title)
                                .padding([.bottom], 5.0)
                                .font(.headline)
                                .lineLimit(2)
                            mediaObject.year.map { year in
                                Text(String(year))
                                    .padding(4.0)
                                    .border(Color.primary, width: 2.0, cornerRadius: 5.0)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Section(header: Text("Basic Information")) {
                        basicText("ID", String(data.id))
                        if !data.genres.isEmpty {
                            basicText("Genres", data.genres.map({ $0.name }).joined(separator: ", "))
                        }
                        basicText("Original Title", data.originalTitle)
                        data.overview.map {
                            longText("Description", $0)
                        }
                        basicText("Status", data.status)
                        basicText("Original Language", JFUtils.languageString(data.originalLanguage))
                    }
                    
                    Section(header: Text("Extended Information")) {
                        data.imdbID.map {
                            link("IMDB ID", $0, link: "https://www.imdb.com/title/\($0)")
                        }
                        data.homepageURL.map {
                            link("Homepage", $0, link: $0)
                        }
                        if !data.productionCompanies.isEmpty {
                            basicText("Production Companies", String(data.productionCompanies.map({ $0.name }).joined(separator: ", ")))
                        }
                        // TMDB Data
                        basicText("Popularity", String(data.popularity))
                        basicText("Scoring", "\(String(format: "%.1f", data.voteAverage))/10.0 points from \(data.voteCount) votes")
                    }
                }
                .listStyle(.grouped)
            }
        }
        .navigationBarTitle(Text(mediaObject.tmdbData?.title ?? ""), displayMode: .inline)
    }
    
    func basicText(_ headline: String, _ text: String) -> some View {
        VStack(alignment: .leading) {
            Text(headline)
                .font(.caption)
            Text(text)
                .lineLimit(nil)
        }
    }
    
    func longText(_ headline: String, _ text: String) -> some View {
        VStack(alignment: .leading) {
            Text(headline)
                .font(.caption)
            // FIXME: This should display as multiple lines, instead of one, currently bugged.
            NavigationLink(destination: LongTextView(text: text, title: "Description")) {
                Text(text)
                    .color(.primary)
                    .lineLimit(3)
            }
        }
    }
    
    func link(_ headline: String, _ text: String, link: String) -> some View {
        return Button(action: {
            if let link = URL(string: link) {
                UIApplication.shared.open(link)
            }
        }, label: {
            VStack(alignment: .leading) {
                Text(headline)
                    .font(.caption)
                    .color(.primary)
                Text(text)
            }
        })
    }
}

struct LongTextView: View {
    
    @State var text: String
    @State var title: String
    
    var body: some View {
        VStack(alignment: .center) {
            Text(text)
                .lineLimit(nil)
                .padding()
            Spacer()
        }
        .navigationBarTitle(title)
    }
    
}

#if DEBUG
struct MediaDetail_Previews : PreviewProvider {
    static var previews: some View {
        //MediaDetail()
        Text("Not implemented")
    }
}
#endif
