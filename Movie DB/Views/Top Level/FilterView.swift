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
// swiftlint:disable:next private_over_fileprivate
fileprivate let nilString = "any"

struct FilterView: View {
    @ObservedObject private var filterSetting = FilterSetting.shared
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // swiftlint:disable:next type_contents_order
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.filterSetting.reset()
                    } label: {
                        Text("Reset")
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Apply")
                    }
                }
            }
        }
    }
}

// swiftlint:disable:next file_types_order
struct UserDataSection: View {
    @ObservedObject var filterSetting: FilterSetting
    
    private var watchedProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watched?.description ?? nilString
        }, set: { bool in
            self.filterSetting.watched = bool.isNil ? nil : Bool(bool)
        })
    }
    
    private var watchAgainProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watchAgain?.description ?? nilString
        }, set: { bool in
            self.filterSetting.watchAgain = bool.isNil ? nil : Bool(bool)
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
        FilterMultiPicker(
            selection: Binding(
                get: { Array(filterSetting.tags).sorted(by: \.name) },
                set: { filterSetting.tags = Set($0) }
            ),
            label: { (tag: Tag) in tag.name },
            values: Array(allTags),
            titleKey: "Tags"
        )
    }
}

// swiftlint:disable:next file_types_order
private struct InformationSection: View {
    @ObservedObject var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
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
            Text("TV Show")
                .tag(MediaType.show.rawValue)
            
                .navigationTitle("Media Type")
        }
        // MARK: - Genres
        let genresProxy = Binding<[Genre]> {
            Array(filterSetting.genres).sorted(by: \.name)
        } set: { newValue in
            filterSetting.genres = Set(newValue)
        }
        FilterMultiPicker(
            selection: genresProxy,
            label: { $0.name },
            values: Utils.allGenres(context: self.managedObjectContext),
            titleKey: "Genres"
        )
        // MARK: - Rating
        NavigationLink(
            destination:
                RangeEditingView(
                    title: Text("Rating"),
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
                } else if self.filterSetting.rating!.count == 1 {
                    // We have to manage plurals on our own here, since the starAmount is a string and we cannot use the Plurals table
                    let amount = self.filterSetting.rating!.lowerBound.starAmount
                    if amount == "1" {
                        Text(String.localizedStringWithFormat("%@ Star", amount))
                            .foregroundColor(.secondary)
                    } else {
                        Text(String.localizedStringWithFormat("%@ Stars", amount))
                            .foregroundColor(.secondary)
                    }
                } else {
                    // We have to manage plurals on our own here, since the starAmount is a string and we cannot use the Plurals table
                    if self.filterSetting.rating!.upperBound.starAmount == "1" {
                        Text(String.localizedStringWithFormat(
                            "%@ to %@ Star",
                            self.filterSetting.rating!.lowerBound.starAmount,
                            self.filterSetting.rating!.upperBound.starAmount
                        ))
                        .foregroundColor(.secondary)
                    } else {
                        Text(String.localizedStringWithFormat(
                            "%@ to %@ Stars",
                            self.filterSetting.rating!.lowerBound.starAmount,
                            self.filterSetting.rating!.upperBound.starAmount
                        ))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        // MARK: - Year
        NavigationLink(destination: RangeEditingView(
            title: Text("Year"),
            bounds: Utils.yearBounds(context: managedObjectContext),
            setting: $filterSetting.year,
            style: .stepper
        )) {
            HStack {
                Text("Year")
                Spacer()
                if self.filterSetting.year == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else if self.filterSetting.year!.count == 1 {
                    // Lower and upper bound are the same
                    Text(self.filterSetting.year!.lowerBound.description)
                        .foregroundColor(.secondary)
                } else {
                    let from = self.filterSetting.year!.lowerBound.description
                    let to = self.filterSetting.year!.upperBound.description
                    Text("\(from) to \(to)")
                        .foregroundColor(.secondary)
                }
            }
        }
        // MARK: - Media Status
        FilterMultiPicker(
            selection: $filterSetting.statuses,
            label: { $0.rawValue },
            values: MediaStatus.allCases.sorted(by: \.rawValue),
            titleKey: "Status"
        )
    }
}

// swiftlint:disable:next file_types_order
private struct ShowSpecificSection: View {
    @ObservedObject var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        // MARK: - Show Type
        FilterMultiPicker(
            selection: $filterSetting.showTypes,
            label: { $0.rawValue },
            values: ShowType.allCases.sorted(by: \.rawValue),
            titleKey: "Show Type"
        )
        // MARK: - Number of Seasons
        NavigationLink(destination: RangeEditingView(
            title: Text("Seasons"),
            bounds: Utils.numberOfSeasonsBounds(context: managedObjectContext),
            setting: self.$filterSetting.numberOfSeasons,
            style: .stepper
        )) {
            HStack {
                Text("Seasons")
                Spacer()
                if self.filterSetting.numberOfSeasons == nil {
                    Text("Any")
                        .foregroundColor(.secondary)
                } else if self.filterSetting.numberOfSeasons!.count == 1 {
                    let formatString = NSLocalizedString(
                        "%lld seasons",
                        tableName: "Plurals",
                        comment: "Season count in filter"
                    )
                    Text(String.localizedStringWithFormat(formatString, self.filterSetting.numberOfSeasons!.lowerBound))
                        .foregroundColor(.secondary)
                } else {
                    let formatString = NSLocalizedString(
                        "%lld to %lld seasons",
                        tableName: "Plurals",
                        comment: "Season range in filter"
                    )
                    Text(String.localizedStringWithFormat(
                        formatString,
                        self.filterSetting.numberOfSeasons!.lowerBound,
                        self.filterSetting.numberOfSeasons!.upperBound
                    ))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}

fileprivate extension String {
    /// Whether this string is equal to the `nilString`
    var isNil: Bool { self == nilString }
}
