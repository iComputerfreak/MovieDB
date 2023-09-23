//
//  ListConfigurationButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 09.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ListConfigurationButton: View {
    @Binding var isShowing: Bool
    
    init(_ isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
    
    var body: some View {
        Button {
            isShowing = true
        } label: {
            Text(Strings.Lists.configureListLabel)
        }
    }
}

#Preview {
    ListConfigurationButton(.constant(false))
}
