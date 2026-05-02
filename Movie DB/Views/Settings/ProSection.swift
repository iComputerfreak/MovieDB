// Copyright © 2022 Jonas Frey. All rights reserved.

import Foundation
import SwiftUI

struct ProSection: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Section(Strings.Settings.proSectionHeader) {
            Button {
                self.config.isShowingProInfo = true
            } label: {
                SettingsActionLabel(
                    title: Strings.Settings.buyProLabel,
                    systemImage: "sparkles.rectangle.stack.fill",
                    tint: .yellow
                )
            }
                .sheet(isPresented: $config.isShowingProInfo) {
                    ProInfoView(source: .settings)
                }
        }
    }
}

#Preview {
    List {
        ProSection(config: .constant(SettingsViewModel()))
    }
}
