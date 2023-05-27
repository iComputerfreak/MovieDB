//
//  MediaMenuLabel.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaMenuLabel: View {
    var body: some View {
        Label(Strings.Detail.mediaMenuLabel, systemImage: "ellipsis.circle")
    }
}

struct MediaMenuLabel_Previews: PreviewProvider {
    static var previews: some View {
        MediaMenuLabel()
    }
}
