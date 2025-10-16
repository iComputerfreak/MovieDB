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

    // To allow toggling the sorting direction, we need to use a custom binding as proxy
    private var sortingOrderProxy: Binding<SortingOrder> {
        Binding<SortingOrder> {
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
    }

    var body: some View {
        Section {
            Picker(selection: sortingOrderProxy) {
                ForEach(SortingOrder.allCases, id: \.rawValue) { order in
                    Button {} label: {
                        Text(order.localized)
                        // If we have the value currently selected, display the sorting direction as a subtitle
                        if self.sortingOrder == order {
                            Text(sortingDirection.localized)
                        }
                    }
                    .tag(order)
                }
            } label: {
                Text(Strings.Library.menuSortingHeader)
            }
        }
    }
}
