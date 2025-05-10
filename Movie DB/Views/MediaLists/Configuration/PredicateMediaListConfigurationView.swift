//
//  DynamicMediaListConfigurationView.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import OSLog
import SwiftUI

struct PredicateMediaListConfigurationView: View {
    @ObservedObject var list: PredicateMediaList
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    init(list: PredicateMediaList) {
        self.list = list
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                if let listDescription = list.listDescription {
                    CalloutView(text: listDescription, type: .info)
                        .padding(.bottom, 16)
                }
                Text(
                    "lists.configuration.header.settings",
                    comment: "The header for the list configuration view's settings section."
                )
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                // We don't show the "use default" option here, because the default behavior is not to use
                // the value in Settings, but instead a fixed value per list type.
                HStack {
                    Text(Strings.Settings.defaultSubtitleContentPickerLabel)
                    Spacer(minLength: 0)
                    SubtitleContentPicker(subtitleContent: $list.subtitleContent, showsUseDefaultOption: false)
                        .labelsHidden()
                }
                Spacer()
            }
            .padding()
            .toolbar {
                DismissButton()
            }
            .navigationTitle(list.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    DynamicMediaListConfigurationView(list: DynamicMediaList(context: PersistenceController.xcodePreviewContext))
}
