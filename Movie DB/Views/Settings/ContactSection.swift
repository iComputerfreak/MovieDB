//
//  ContactSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ContactSection: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Section {
            Link(Strings.Settings.feedbackLabel, destination: URL(string: "mailto:feedback@jonasfreyapps.de")!)
        }
    }
}

#Preview {
    ContactSection(config: .constant(.init()))
}
