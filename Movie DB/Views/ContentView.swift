//
//  ContentView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        TabbedView {
            LibraryHome()
                .tag(0)
                .tabItemLabel(Text("Library"))
            
            AddMediaView()
                .tag(1)
                .tabItemLabel(Text("Add Movie"))
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
