// Copyright © 2021 Jonas Frey. All rights reserved.

import SwiftUI

struct LegalView: View {
    @EnvironmentObject private var config: JFConfig

    @State private var isShowingCopyConfirmation = false

    var tmdbLogo: some View {
        Image(platformImage: NSUIImage.tmDbLogo)
            .resizable()
            .scaledToFit()
            .frame(height: 20)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(Strings.Legal.privacyPolicyButtonTitle) {
                    PrivacyPolicyView()
                }

                NavigationLink(Strings.Legal.imprintButtonTitle) {
                    ImprintView()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.Legal.analyticsIdentifierTitle)
                        .font(.headline)

                    Text(Strings.Legal.analyticsIdentifierDescription)
                        .foregroundStyle(.secondary)

                    Text(verbatim: config.analyticsInstallationID)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)

                    Button(Strings.Legal.analyticsIdentifierCopyButton) {
                        Clipboard.copy(config.analyticsInstallationID)
                        isShowingCopyConfirmation = true
                    }
                }

                Divider()

                Text(verbatim: """
                This app uses data from The Movie Database.
                This product uses the TMDb API but is not endorsed or certified by TMDb.
                """)
                HStack {
                    tmdbLogo
                    Link(
                        // Cast to String to prevent localization
                        "https://www.themoviedb.org/" as String,
                        destination: URL(string: "https://www.themoviedb.org/")!
                    )
                }
                Divider()
                // swiftlint:disable:next force_try
                let mail = try! AttributedString(markdown: "[legal@jonasfreyapps.de](mailto:legal@joansfreyapps.de)")
                Text(Strings.Legal.legalNoticeMail(mail))
                Divider()
                // swiftlint:disable:next force_try
                let link = try! AttributedString(markdown: "[https://uxwing.com](https://uxwing.com)")
                Text(Strings.Legal.appIconAttribution(link))
            }
        }
        .lineLimit(nil)
        .padding()
        .navigationTitle(Strings.Legal.navBarTitle)
        .notificationPopup(
            isPresented: $isShowingCopyConfirmation,
            systemImage: "doc.on.doc",
            title: Strings.Legal.analyticsIdentifierCopied
        )
    }
}

#Preview {
    NavigationStack {
        LegalView()
    }
}
