//
//  ThumbnailModifier.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    
    func thumbnail(multiplier: CGFloat = 1.0) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: JFLiterals.thumbnailSize.width * multiplier, height: JFLiterals.thumbnailSize.height * multiplier, alignment: .center)
    }
    
}
