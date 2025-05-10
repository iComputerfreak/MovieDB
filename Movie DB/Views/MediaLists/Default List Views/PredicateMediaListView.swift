//
//  DynamicMediaListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct PredicateMediaListView<RowContent: View, MoreMenuItemContent: View>: View {
    @Binding var selectedMediaObjects: Set<Media>
    @ObservedObject private var list: PredicateMediaList
    private let rowContent: (Media) -> RowContent
    private let extraMoreMenuItems: () -> MoreMenuItemContent
    @State private var isShowingConfiguration = false

    init(
        selectedMediaObjects: Binding<Set<Media>>,
        list: PredicateMediaList,
        @ViewBuilder rowContent: @escaping (Media) -> RowContent,
        @ViewBuilder extraMoreMenuItems: @escaping () -> MoreMenuItemContent = { EmptyView() }
    ) {
        self._selectedMediaObjects = selectedMediaObjects
        self.list = list
        self.rowContent = rowContent
        self.extraMoreMenuItems = extraMoreMenuItems
    }

    var body: some View {
        FilteredMediaList(
            list: list,
            selectedMediaObjects: $selectedMediaObjects,
            rowContent: rowContent,
            extraMoreMenuItems: extraMoreMenuItems
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
