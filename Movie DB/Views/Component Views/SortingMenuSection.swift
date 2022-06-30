//
//  SortingMenuSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct SortingMenuSection: View {
    @Binding var sortingOrder: SortingOrder
    @Binding var sortingDirection: SortingDirection
    
    var body: some View {
        Section {
            // To allow toggling the sorting direction, we need to use a custom binding as proxy
            let sortingOrderProxy = Binding<SortingOrder> {
                self.sortingOrder
            } set: { newValue in
                // Animate the sorting change
                withAnimation {
                    if self.sortingOrder == newValue {
                        // Toggle the direction when tapping an already selected item
                        self.sortingDirection.toggle()
                    } else {
                        // Otherwise, use the default direction for this sorting order
                        self.sortingDirection = newValue.defaultDirection
                    }
                    self.sortingOrder = newValue
                }
            }
            Picker(selection: sortingOrderProxy) {
                ForEach(SortingOrder.allCases, id: \.rawValue) { order in
                    if self.sortingOrder == order {
                        let image = sortingDirection == .ascending ? "chevron.up" : "chevron.down"
                        Label(order.localized, systemImage: image)
                            .tag(order)
                    } else {
                        Text(order.localized)
                            .tag(order)
                    }
                }
            } label: {
                Text(Strings.Library.menuSortingHeader)
            }
        }
    }
}
