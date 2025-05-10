//
//  CalloutView.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

enum CalloutType: CaseIterable {
    case info
    case warning
    case error
    case important
    
    var symbol: Image {
        switch self {
        case .info:
            return Image(systemName: "info")
        case .warning:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .error:
            return Image(systemName: "exclamationmark.octagon.fill")
        case .important:
            return Image(systemName: "exclamationmark")
        }
    }
    
    var foregroundColor: Color? {
        switch self {
        case .info, .warning, .error:
            return nil
        case .important:
            return .pink
        }
    }
}

struct CalloutView: View {
    let text: String
    let type: CalloutType
    let iconSize: CGFloat = 20
    
    init(text: String, type: CalloutType) {
        self.text = text
        self.type = type
    }
    
    var body: some View {
        HStack {
            type.symbol
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(type.foregroundColor)
                .frame(maxWidth: iconSize, maxHeight: iconSize)
            Text(text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CalloutBackground"))
        }
    }
}

#Preview("Short Text") {
    VStack {
        ForEach(CalloutType.allCases, id: \.hashValue) { type in
            CalloutView(text: "Callout Text", type: type)
                .padding()
        }
    }
}

#Preview("Multiline") {
    VStack {
        ForEach(CalloutType.allCases, id: \.hashValue) { type in
            CalloutView(text: "This is a very long callout text that wraps multiple lines.", type: type)
                .padding()
        }
    }
}
