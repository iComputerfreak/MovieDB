//
//  DeleteMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct DeleteMediaButton: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Button(role: .destructive) {
            // Delete the media
            self.managedObjectContext.delete(mediaObject)
            onDelete?()
        } label: {
            Label(Strings.Library.swipeActionDelete, systemImage: "trash")
        }
    }
}

struct DeleteMediaButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteMediaButton()
            .environmentObject(PlaceholderData.preview.staticMovie)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
