// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct AddEnvironmentMediaToListMenu: View {
    @EnvironmentObject private var mediaObject: Media
    var onAction: (() -> Void)? = nil
    var onCompletion: (() -> Void)?
    
    var body: some View {
        AddToListMenu(mediaObjects: [mediaObject], onAction: onAction, onCompletion: onCompletion)
    }
}

struct AddMultipleToListMenu: View {
    var mediaObjects: Set<Media>
    var onAction: (() -> Void)? = nil
    var onCompletion: (() -> Void)?
    
    var body: some View {
        AddToListMenu(mediaObjects: mediaObjects, onAction: onAction, onCompletion: onCompletion)
    }
}

private struct AddToListMenu: View {
    @EnvironmentObject private var notificationProxy: NotificationProxy
    
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: Schema.UserMediaList.name.rawValue, ascending: true)]
    )
    private var userLists: FetchedResults<UserMediaList>
    
    var mediaObjects: Set<Media>
    var onAction: (() -> Void)?
    var onCompletion: (() -> Void)?
    
    init(mediaObjects: Set<Media>, onAction: (() -> Void)? = nil, onCompletion: (() -> Void)? = nil) {
        self.mediaObjects = mediaObjects
        self.onAction = onAction
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        Menu {
            ForEach(userLists) { (list: UserMediaList) in
                Button {
                    onAction?()
                    for media in mediaObjects {
                        media.userLists.insert(list)
                    }
                    notificationProxy.show(
                        title: Strings.Detail.addedToListNotificationTitle,
                        subtitle: Strings.Detail.addedToListNotificationMessage(list.name),
                        systemImage: "checkmark"
                    )
                    onCompletion?()
                } label: {
                    Label(list.name, systemImage: list.iconName)
                }
                // Disable the "Add to..." button if the all media objects are already on the list
                // !!!: Does not seem to work in simulator, but works on a real device
                .disabled(mediaObjects.map(\.userLists).allSatisfy({ $0.contains(list) }))
            }
        } label: {
            Label(Strings.Library.mediaActionAddToList, systemImage: "text.badge.plus")
        }
        .disabled(mediaObjects.isEmpty)
    }
}

#Preview {
    List {
        AddEnvironmentMediaToListMenu()
            .previewEnvironment()
        
        AddMultipleToListMenu(mediaObjects: [PlaceholderData.preview.staticMovie])
            .previewEnvironment()
    }
}
