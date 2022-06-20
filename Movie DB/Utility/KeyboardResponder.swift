//
//  KeyboardResponder.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

/// Represents an observable object, that notifies views of keyboard size updates
final class KeyboardResponder: ObservableObject {
    let center: NotificationCenter
    /// The current height of the keyboard
    @Published private(set) var height: CGFloat = 0
    
    init(_ center: NotificationCenter = .default) {
        self.center = center
        self.center.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        self.center.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc
    func keyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if let keyboardSize = keyboardFrame?.cgRectValue {
            self.height = keyboardSize.height
        }
    }
    
    @objc
    func keyboardWillHide(notification: Notification) {
        self.height = 0
    }
    
    deinit {
        self.center.removeObserver(self)
    }
}
