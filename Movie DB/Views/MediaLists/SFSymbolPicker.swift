//
//  SFSymbolPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SFSymbolPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var symbol: String
    
    let gridItemSize: CGFloat = 40
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    .init(
                        .adaptive(
                            minimum: gridItemSize,
                            maximum: gridItemSize
                        ),
                        spacing: 8,
                        alignment: .center
                    ),
                ],
                alignment: .center,
                spacing: 5,
                pinnedViews: .sectionHeaders
            ) {
                ForEach(SFSymbolNames.curatedSymbols, id: \.self) { symbol in
                    Button {
                        self.symbol = symbol
                        self.dismiss()
                    } label: {
                        Image(systemName: symbol)
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .scaledToFit()
                            .frame(width: gridItemSize, height: gridItemSize)
                            .foregroundColor(.accentColor)
                            .padding(2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SFSymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SFSymbolPicker(symbol: .constant("heart.fill"))
        }
    }
}
