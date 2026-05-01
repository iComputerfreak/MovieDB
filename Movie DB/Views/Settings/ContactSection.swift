// Copyright © 2022 Jonas Frey. All rights reserved.

import SwiftUI

struct ContactSection: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Section(Strings.Settings.supportSectionHeader) {
            Link(destination: URL(string: "mailto:feedback@jonasfreyapps.de")!) {
                SettingsActionLabel(
                    title: Strings.Settings.feedbackLabel,
                    systemImage: "envelope.fill",
                    tint: .blue
                )
            }
        }
    }
}

#Preview {
    ContactSection(config: .constant(.init()))
}
