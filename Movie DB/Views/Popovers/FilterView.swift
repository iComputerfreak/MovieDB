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
    
    @ObservedObject private var filterSetting = FilterSetting.shared
    
    @Environment(\.presentationMode) private var presentationMode
        
    init() {}
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Data")) {
                    UserDataSection(filterSetting: filterSetting)
                }
                Section(header: Text("Information")) {
                    InformationSection(filterSetting: filterSetting)
                }
                Section(header: Text("Show specific")) {
                    ShowSpecificSection(filterSetting: filterSetting)
                }
            }
            .navigationBarTitle("Filter Options")
            .navigationBarItems(leading: Button(action: {
                self.filterSetting.reset()
            }, label: Text("Reset").closure()), trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: Text("Apply").closure()))
        }
    }
}

struct UserDataSection: View {
    
    @ObservedObject var filterSetting: FilterSetting
    
    private var watchedProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watched?.description ?? nilString
        }, set: { bool in
            self.filterSetting.watched = bool.isNil ? nil : Bool(bool) ?? nil
        })
    }
    
    private var watchAgainProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watchAgain?.description ?? nilString
        }, set: { bool in
            self.filterSetting.watchAgain = bool.isNil ? nil : Bool(bool) ?? nil
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
            
                .navigationTitle("Watched?")
        }
        // MARK: - Watch Again?
        Picker("Watch again?", selection: watchAgainProxy) {
            Text("Any")
                .tag(nilString)
            Text("Yes")
                .tag(true.description)
            Text("No")
                .tag(false.description)
            
                .navigationTitle("Watch again?")
        }
        // MARK: - Tags
        // TODO: First selected item does not update the view
        FilterMultiPicker(
            selection: Binding(
                get: { Array(filterSetting.tags).sorted(by: \.name) },
                set: { filterSetting.tags = Set($0) }),
            label: { (tag: Tag) in tag.name },
            values: Array(allTags),
            title: Text("Tags")
        )
    }
}

private struct InformationSection: View {
    
    @ObservedObject var filterSetting: FilterSetting
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSetting.mediaType?.rawValue ?? nilString
        }, set: { type in
            self.filterSetting.mediaType = type.isNil ? nil : MediaType(rawValue: type)
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
            
                .navigationTitle("Media Type")
        }
        // MARK: - Genres
        let genresProxy = Binding<[Genre]> {
            Array(filterSetting.genres).sorted(by: \.name)
        } set: { (newValue) in
            filterSetting.genres = Set(newValue)
        }
        FilterMultiPicker(selection: genresProxy, label: { $0.name }, values: JFUtils.allGenres(), title: Text("Genres"))
        // MARK: - Rating
        NavigationLink(
            destination:
                RangeEditingView(
                    title: NSLocalizedString("Rating", comment: ""),
                    bounds: StarRating.noRating...StarRating.fiveStars,
                    setting: $filterSetting.rating,
                    style: .stepper,
                    valueLabel: { RatingView(rating: .constant($0)) }
                )
        ) {
            HStack {
                Text("Rating")
                Spacer()
                if self.filterSetting.rating == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(self.filterSetting.rating!.lowerBound.starAmount) to \(self.filterSetting.rating!.upperBound.starAmount) stars", tableName: "Plurals")
                        .foregroundColor(.secondary)
                }
            }
        }
        // MARK: - Year
        NavigationLink(destination: RangeEditingView(title: "Year", bounds: JFUtils.yearBounds(), setting: $filterSetting.year, style: .wheel)) {
            HStack {
                Text("Year")
                Spacer()
                if self.filterSetting.year == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(self.filterSetting.year!.lowerBound.description) to \(self.filterSetting.year!.upperBound.description)")
                        .foregroundColor(.secondary)
                }
            }
        }
        // MARK: - Media Status
        FilterMultiPicker(selection: $filterSetting.statuses, label: { $0.rawValue }, values: MediaStatus.allCases.sorted(by: \.rawValue), title: Text("Status"))
    }
}

private struct ShowSpecificSection: View {
    
    @ObservedObject var filterSetting: FilterSetting
    
    var body: some View {
        // MARK: - Show Type
        FilterMultiPicker(selection: $filterSetting.showTypes, label: { $0.rawValue }, values: ShowType.allCases.sorted(by: \.rawValue), title: Text("Show Type"))
        // MARK: - Number of Seasons
        NavigationLink(destination: RangeEditingView(title: "Seasons", bounds: JFUtils.numberOfSeasonsBounds(), setting: self.$filterSetting.numberOfSeasons, style: .stepper)) {
            HStack {
                Text("Seasons")
                Spacer()
                if self.filterSetting.numberOfSeasons == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(self.filterSetting.numberOfSeasons!.lowerBound) to \(self.filterSetting.numberOfSeasons!.upperBound) seasons", tableName: "Plurals")
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
