//
//  FilterView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// The string representing a `nil` value in a `Picker`
fileprivate let nilString = "any"

struct FilterView: View {
    
    @ObservedObject private var filterSettings = FilterSettings.shared
    
    @Environment(\.presentationMode) private var presentationMode
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSettings.mediaType?.rawValue ?? nilString
        }, set: { type in
            self.filterSettings.mediaType = type.isNil ? nil : MediaType(rawValue: type)
        })
    }
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
        
    init() {}
    
    func onDisappear() {
        // Save the filter settings
        FilterSettings.save()
    }
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Data")) {
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
                    FilterMultiPicker(selection: $filterSettings.tags, label: { TagLibrary.shared.name(for: $0) ?? "<Unknown>" }, values: TagLibrary.shared.tags.map { $0.id }, title: Text("Tags"))
                }
                Section(header: Text("Information")) {
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
                    FilterMultiPicker(selection: $filterSettings.genres, label: { $0.name }, values: Genre.allGenres, title: Text("Genres"))
                    // MARK: - Rating
                    NavigationLink(destination: RangeEditingView(bounds: 0...JFLiterals.maximumRating, setting: $filterSettings.rating, style: .stepper, valueLabel: { RatingView(rating: .constant($0)) })) {
                        HStack {
                            Text("Rating")
                            Spacer()
                            if self.filterSettings.rating == nil {
                                Text("Any")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(self.filterSettings.rating!.lowerBound.divided(by: 2)) to \(self.filterSettings.rating!.upperBound.divided(by: 2)) stars")
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
                    FilterMultiPicker(selection: $filterSettings.status, label: { $0.rawValue }, values: MediaStatus.allCases, title: Text("Status"))
                }
                Section(header: Text("Show specific")) {
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
            .navigationBarTitle("Filter Options")
            .navigationBarItems(leading: Button(action: {
                self.filterSettings.reset()
            }, label: Text("Reset").closure()), trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: Text("Apply").closure()))
        }
    .onDisappear(perform: onDisappear)
    }
}

fileprivate extension Int {
    /// Returns the result of the division rounded to one fraction digit
    /// - Parameter int: The number to divide by
    func divided(by int: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: Double(self) / Double(int))!
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
