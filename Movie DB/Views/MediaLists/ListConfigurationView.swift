//
//  ListConfigurationView.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a form that allows editing of a list with a Done button and a navigation title
struct ListConfigurationView<ListType, Content: View>: View where ListType: MediaListProtocol & ObservableObject {
    @ObservedObject var list: ListType
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder var contentBuilder: (ListType) -> Content
    
    var body: some View {
        NavigationStack {
            Form {
                contentBuilder(list)
            }
            .navigationTitle(list.name)
            .toolbar {
                Button(Strings.Generic.dismissViewDone) {
                    dismiss()
                }
            }
        }
    }
}

struct ListConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ListConfigurationView(list: UserMediaList(context: PersistenceController.previewContext)) { list in
            Text(verbatim: "Name: \(list.name)")
        }
    }
}
