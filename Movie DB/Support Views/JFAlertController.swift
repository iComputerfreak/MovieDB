//
//  JFAlertController.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.03.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents an object that stores the data and presentation status of an alert view in SwiftUI
///
/// Example
/// -----
///     @ObservedObject private var alertController = AlertController()
///
///     var body: some View {
///         Button(action: {
///             alertController.present(title: "Test")
///         }) {
///             Text("Present")
///         }
///         .alert(isPresented: $alertController.isShown, content: alertController.buildAlert)
///     }
///
class AlertController: ObservableObject {
    
    // This is the only variable that should be @Published, because all others will be immutable after creating the alert using `buildAlert` and therefore should not cause UI updates.
    @Published var isShown: Bool = false
    
    private var alertObject: Alert!
    
    /// Returns the Alert object to use in the `alert(isPresented:content:)` function.
    func buildAlert() -> Alert { alertObject }
    
    func present(title: String, message: String? = nil, dismissButton: Alert.Button? = nil) {
        print("Presenting Alert: '\(title)'")
        self.alertObject = Alert(title: Text(title),
                                 message: message != nil ? Text(message!) : nil,
                                 dismissButton: dismissButton)
        self.isShown = true
    }
    
    func present(title: String, message: String? = nil, primaryButton: Alert.Button, secondaryButton: Alert.Button) {
        print("Presenting Alert: '\(title)'")
        self.alertObject = Alert(title: Text(title),
                                 message: message != nil ? Text(message!) : nil,
                                 primaryButton: primaryButton,
                                 secondaryButton: secondaryButton)
        self.isShown = true
    }
    
}

struct AlertController_Previews: PreviewProvider {
    
    @ObservedObject static var alertController = AlertController()
    
    static var previews: some View {
        VStack {
            Button(action: {
                alertController.present(title: "Test title")
            }) {
                Text("Present")
            }
        }
        .alert(isPresented: $alertController.isShown, content: alertController.buildAlert)
    }
}

