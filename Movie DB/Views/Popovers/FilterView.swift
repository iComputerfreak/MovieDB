//
//  FilterView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

/// The string representing a `nil` value in a `Picker`
fileprivate let nilString = "any"

struct FilterView: View {
    
    @ObservedObject private var filterSettings = FilterSetting.shared
    
    @Environment(\.presentationMode) private var presentationMode
        
    init() {}
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Data")) {
                    UserDataSection(filterSettings: filterSettings)
                }
                Section(header: Text("Information")) {
                    InformationSection(filterSettings: filterSettings)
                }
                Section(header: Text("Show specific")) {
                    ShowSpecificSection(filterSettings: filterSettings)
                }
            }
            .navigationBarTitle("Filter Options")
            .navigationBarItems(leading: Button(action: {
                self.filterSettings.reset()
            }, label: Text("Reset").closure()), trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: Text("Apply").closure()))
        }
    }
}

struct UserDataSection: View {
    
    @State var filterSettings: FilterSetting
    
    private var watchedProxy: Binding<String> {
        .init(get: {
            self.filterSettings.watched?.description ?? nilString
        }, set: { bool in
            self.filterSettings.watched = bool.isNil ? nil : Bool(bool) ?? nil
        })
    }
    
    private var watchAgainProxy: Binding<String> {
        .init(get: {
            self.filterSettings.watchAgain?.description ?? nilString
        }, set: { bool in
            self.filterSettings.watchAgain = bool.isNil ? nil : Bool(bool) ?? nil
        })
    }
    
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var allTags: FetchedResults<Tag>
    
    var body: some View {
        // MARK: - Watched?
        Picker("Watched?", selection: watchedProxy) {
            Text("Any")
                .tag(nilString)
            Text("Yes")
                .tag(true.description)
            Text("No")
                .tag(false.description)
        }
        // MARK: - Watch Again?
        Picker("Watch again?", selection: watchAgainProxy) {
            Text("Any")
                .tag(nilString)
            Text("Yes")
                .tag(true.description)
            Text("No")
                .tag(false.description)
        }
        // MARK: - Tags
        FilterMultiPicker(
            selection: Binding(
                get: { Array(filterSettings.tags) },
                set: { filterSettings.tags = Set($0) }),
            label: { $0.name },
            values: allTags,
            title: Text("Tags")
        )
    }
}

private struct InformationSection: View {
    
    @State var filterSettings: FilterSetting
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSettings.mediaType?.rawValue ?? nilString
        }, set: { type in
            self.filterSettings.mediaType = type.isNil ? nil : MediaType(rawValue: type)
        })
    }
    
    var body: some View {
        // MARK: - Media Type
        Picker("Media Type", selection: mediaTypeProxy) {
            Text("Any")
                .tag(nilString)
            Text("Movie")
                .tag(MediaType.movie.rawValue)
            Text("Show")
                .tag(MediaType.show.rawValue)
        }
        // MARK: - Genres
        let genresProxy = Binding<[Genre]> {
            Array(filterSettings.genres).sorted(by: \.name)
        } set: { (newValue) in
            filterSettings.genres = Set(newValue)
        }
        FilterMultiPicker(selection: genresProxy, label: { $0.name }, values: JFUtils.allGenres(), title: Text("Genres"))
        // MARK: - Rating
        NavigationLink(destination: RangeEditingView(bounds: StarRating.noRating...StarRating.fiveStars, setting: $filterSettings.rating, style: .stepper, valueLabel: { RatingView(rating: .constant($0)) })) {
            HStack {
                Text("Rating")
                Spacer()
                if self.filterSettings.rating == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(self.filterSettings.rating!.lowerBound.starAmount) to \(self.filterSettings.rating!.upperBound.starAmount) stars")
                        .foregroundColor(.secondary)
                }
            }
        }
        // MARK: - Year
        NavigationLink(destination: RangeEditingView(bounds: JFUtils.yearBounds(), setting: $filterSettings.year, style: .wheel)) {
            HStack {
                Text("Year")
                Spacer()
                if self.filterSettings.year == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(self.filterSettings.year!.lowerBound.description) to \(self.filterSettings.year!.upperBound.description)")
                        .foregroundColor(.secondary)
                }
            }
        }
        // MARK: - Media Status
        FilterMultiPicker(selection: $filterSettings.statuses, label: { $0.rawValue }, values: MediaStatus.allCases, title: Text("Status"))
    }
}

private struct ShowSpecificSection: View {
    
    @State var filterSettings: FilterSetting
    
    var body: some View {
        // MARK: - Show Type
        FilterMultiPicker(selection: $filterSettings.showTypes, label: { $0.rawValue }, values: ShowType.allCases, title: Text("Show Type"))
        // MARK: - Number of Seasons
        NavigationLink(destination: RangeEditingView(bounds: JFUtils.numberOfSeasonsBounds(), setting: self.$filterSettings.numberOfSeasons, style: .stepper)) {
            HStack {
                Text("Seasons")
                Spacer()
                if self.filterSettings.numberOfSeasons == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(self.filterSettings.numberOfSeasons!.lowerBound) to \(self.filterSettings.numberOfSeasons!.upperBound) seasons")
                        .foregroundColor(.secondary)
                }
            }
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
