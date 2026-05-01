//
//  ListIconPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ListIconPicker: View {
    @Binding var symbolName: String

    var symbolsPerRow: Int {
        // TODO: Differentiate by device or available space
        // Alternatively, we could use a WrappingHStack with same-sized children
        return 6
    }

    var body: some View {
        LazyVGrid(
            columns: .init(
                repeating: .init(.adaptive(minimum: 40, maximum: 50), alignment: .center), count: 6
            ),
            alignment: .center,
            spacing: nil,
            pinnedViews: []
        ) {
            ForEach(SFSymbolNames.curatedSymbols.chunked(into: symbolsPerRow), id: \.self) { row in
                ForEach(row, id: \.self) { icon in
                    ZStack {
                        Circle()
                            .fill(.gray90)
                            .padding(4)
                        Image(systemName: icon)
                        Circle()
                            .stroke(.gray, lineWidth: 2.0)
                            .opacity(self.symbolName == icon ? 1.0 : 0.0)
                    }
                    .frame(width: 45)
                    .onTapGesture {
                        self.symbolName = icon
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var symbolName = "heart"
    VStack {
        Text(verbatim: "Selection does not work in Preview!")
            .foregroundColor(.red)
            .bold()
        List {
            ListIconPicker(symbolName: $symbolName)
        }
    }
}
