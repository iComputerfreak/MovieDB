//
//  ProInfoView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProInfoView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    Text("Remove the limit of \(JFLiterals.nonProMediaLimit) objects by buying the Pro version of the app.")
                        .padding()
                    Spacer()
                }
                Spacer()
                // TODO: Make new button style (rounded)
                Button("Buy Pro - $4.99") {
                    // TODO: Implement
                    print("Buying Pro")
                }
            }
            .navigationTitle("Movie DB Pro")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                    Button("Restore") {
                        // TODO: Implement
                        print("Restoring Purchases")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // TODO: Test if this works. Does not work in simulator
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ProInfoView_Previews: PreviewProvider {
    
    @State private static var isShowing: Bool = true
    
    static var previews: some View {
        Text("Hello, world!")
            .popover(isPresented: $isShowing, content: {
                ProInfoView()
            })
    }
}
