//
//  ProSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct ProSection: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Section(Strings.Settings.proSectionHeader) {
            Button(action: { self.config.isShowingProInfo = true }) {
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
