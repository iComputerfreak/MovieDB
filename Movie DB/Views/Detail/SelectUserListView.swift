// Copyright © 2022 Jonas Frey. All rights reserved.

import CoreData
import SwiftUI

/// A list to allow the user to select a UserMediaList
struct SelectUserListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: Schema.UserMediaList.name.rawValue, ascending: true)]
    )
    private var lists: FetchedResults<UserMediaList>
    
    @ObservedObject var mediaObject: Media
    
    var body: some View {
        NavigationStack {
            List(lists) { list in
                let isDisabled = list.medias.contains(mediaObject)
                Button {
                    mediaObject.userLists.insert(list)
                    dismiss()
                } label: {
                    Label(list.name, systemImage: list.iconName)
                }
                .disabled(isDisabled)
                .foregroundColor(isDisabled ? .gray : .primary)
            }
            .navigationTitle(Strings.AddToList.title)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Strings.AddToList.toolbarButtonCancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SelectUserListView(mediaObject: PlaceholderData.preview.staticMovie)
        .previewEnvironment()
}
