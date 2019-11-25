//
//  KeyboardResponder.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

final class KeyboardResponder: ObservableObject {
    
    let center: NotificationCenter
    @Published private(set) var height: CGFloat = 0
    
    init(_ center: NotificationCenter = .default) {
        self.center = center
        self.center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        self.center.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        print("[Responder] Keyboard will show")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.height = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("[Responder] Keyboard will hide")
        self.height = 0
    }
    
}
