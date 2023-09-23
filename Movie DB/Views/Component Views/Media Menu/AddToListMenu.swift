//
//  AddToListMenu.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct AddToListMenu: View {
    @EnvironmentObject private var mediaObject: Media
    @EnvironmentObject private var notificationProxy: NotificationProxy
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: Schema.UserMediaList.name.rawValue, ascending: true)]
    )
    private var userLists: FetchedResults<UserMediaList>
    
    var body: some View {
        Menu {
            ForEach(userLists) { (list: UserMediaList) in
                Button {
                    mediaObject.userLists.insert(list)
                    notificationProxy.show(
                        title: Strings.Detail.addedToListNotificationTitle,
                        subtitle: Strings.Detail.addedToListNotificationMessage(list.name),
                        systemImage: "checkmark"
                    )
                } label: {
                    Label(list.name, systemImage: list.iconName)
                }
                // Disable the "Add to..." button if the media is already in the list
                // !!!: Does not seem to work in simulator, but works on real device
                .disabled(mediaObject.userLists.contains(list))
            }
        } label: {
            Label(Strings.Library.mediaActionAddToList, systemImage: "text.badge.plus")
        }
    }
}

#Preview {
    AddToListMenu()
        .previewEnvironment()
}
