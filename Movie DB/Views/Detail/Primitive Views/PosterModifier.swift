//
//  PosterModifier.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    
    func poster() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height, alignment: .center)
    }
    
}
