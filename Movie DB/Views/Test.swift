//
//  Test.swift
//  Movie DB
//
//  Created by Jonas Frey on 09.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct Test : View {
    var body: some View {
        VStack {
            foo("Hello")
            foo("Hello")
            foo("Hello")
            foo("Hello")
            foo("Hello")
        }
    }
    
    func foo(_ text: String) -> Text {
        return Text(text)
    }
}

#if DEBUG
struct Test_Previews : PreviewProvider {
    static var previews: some View {
        Test()
    }
}
#endif
