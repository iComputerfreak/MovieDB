// Copyright © 2023 Jonas Frey. All rights reserved.

import UIKit

extension UIColor {
    convenience init(cdColor: CDColor) {
        self.init(
            red: cdColor.redComponent,
            green: cdColor.greenComponent,
            blue: cdColor.blueComponent,
            alpha: cdColor.alphaComponent
        )
    }
}
