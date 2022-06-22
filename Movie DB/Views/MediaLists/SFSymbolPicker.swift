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
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [.init(.adaptive(minimum: 30, maximum: 30), spacing: 5, alignment: .center)],
                alignment: .leading,
                spacing: 5,
                pinnedViews: .sectionHeaders
            ) {
                ForEach(SFSymbolNames.categories, id: \.name) { category in
                    Section {
                        ForEach(category.symbols, id: \.self) { symbol in
                            Button {
                                self.symbol = symbol
                                self.dismiss()
                            } label: {
                                Image(systemName: symbol)
                                    .symbolRenderingMode(.multicolor)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            Spacer()
                            Label(category.name, systemImage: category.iconName)
                                .font(.headline.bold())
                            Divider()
                        }
                        .background(Color.systemBackground)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SFSymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SFSymbolPicker(symbol: .constant("heart.fill"))
        }
    }
}
