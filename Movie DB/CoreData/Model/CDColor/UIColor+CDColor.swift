// Copyright © 2023 Jonas Frey. All rights reserved.

extension NSUIColor {
    convenience init(cdColor: CDColor) {
        self.init(
            red: cdColor.redComponent,
            green: cdColor.greenComponent,
            blue: cdColor.blueComponent,
            alpha: cdColor.alphaComponent
        )
    }
}
