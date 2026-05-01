// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct WatchDateView: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing
    
    var body: some View {
        if isEditing {
            EditingView()
        } else {
            let watchDateString = mediaObject.watchDate?.formatted(date: .complete, time: .omitted)
            Text(watchDateString ?? Strings.Generic.unknown)
        }
    }
    
    struct EditingView: View {
        @EnvironmentObject private var mediaObject: Media
        
        var body: some View {
            VStack {
                Toggle(isOn: Binding(
                    get: {
                        mediaObject.watchDate != nil
                    }, set: { newValue in
                        // If the toggle is set to "on"
                        if newValue == true {
                            mediaObject.watchDate = Date()
                        } else {
                            mediaObject.watchDate = nil
                        }
                    }
                )) {
                    EmptyView()
                    Text(Strings.Detail.watchDateKnownToggleLabel)
                }
                .padding(.trailing)
                
                if mediaObject.watchDate != nil {
                    DatePicker(
                        selection: Binding(
                            get: {
                                mediaObject.watchDate ?? Date()
                            }, set: { newValue in
                                mediaObject.watchDate = newValue
                            }
                        ),
                        in: Date.distantPast...Date(),
                        displayedComponents: .date
                    ) {
                        Text(Strings.Detail.watchDateHeadline)
                    }
                    .datePickerStyle(.graphical)
                    .animation(.easeIn(duration: 1), value: mediaObject.watchDate == nil)
                    .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    List {
        WatchDateView()
        WatchDateView()
            .environment(\.isEditing, true)
    }
    .previewEnvironment()
}
