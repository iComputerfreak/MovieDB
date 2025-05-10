//
//  DynamicMediaListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct PredicateMediaListView<RowContent: View>: View {
    @Binding var selectedMediaObjects: Set<Media>
    @ObservedObject private var list: PredicateMediaList
    private let rowContent: (Media) -> RowContent
    @State private var isShowingConfiguration = false

    init(
        selectedMediaObjects: Binding<Set<Media>>,
        list: PredicateMediaList,
        @ViewBuilder rowContent: @escaping (Media) -> RowContent
    ) {
        self._selectedMediaObjects = selectedMediaObjects
        self.list = list
        self.rowContent = rowContent
    }

    var body: some View {
        FilteredMediaList(
            list: list,
            selectedMediaObjects: $selectedMediaObjects,
            rowContent: rowContent
        )
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            PredicateMediaListConfigurationView(list: list)
        }
    }
}

#Preview {
    PredicateMediaListView(selectedMediaObjects: .constant([]), list: PredicateMediaList.favorites) { media in
        LibraryRow().environmentObject(media)
    }
}
