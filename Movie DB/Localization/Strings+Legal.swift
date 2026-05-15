// Copyright © 2022 Jonas Frey. All rights reserved.

import Foundation

extension Strings {
    enum Legal {
        static let navBarTitle = String(
            localized: "legal.navBar.title",
            comment: "The navigation bar title for the legal view"
        )
        static let privacyPolicyTitle = String(
            localized: "legal.privacyPolicy.title",
            comment: "The navigation bar title for the privacy policy view."
        )
        static let privacyPolicyButtonTitle = String(
            localized: "legal.privacyPolicy.button",
            comment: "The button title that opens the privacy policy from the legal view."
        )
        static let privacyPolicyLanguagePickerTitle = String(
            localized: "legal.privacyPolicy.languagePicker",
            comment: "Accessibility label for the privacy policy language picker."
        )
        static let privacyPolicyLanguageEnglish = String(
            localized: "legal.privacyPolicy.language.english",
            comment: "English label in the privacy policy language picker."
        )
        static let privacyPolicyLanguageGerman = String(
            localized: "legal.privacyPolicy.language.german",
            comment: "German label in the privacy policy language picker."
        )
        static let privacyPolicyLoadError = String(
            localized: "legal.privacyPolicy.loadError",
            comment: "Fallback text when the bundled privacy policy cannot be loaded."
        )
        static let analyticsIdentifierTitle = String(
            localized: "legal.analyticsIdentifier.title",
            comment: "Title shown above the analytics installation identifier in the legal view."
        )
        static let analyticsIdentifierDescription = String(
            localized: "legal.analyticsIdentifier.description",
            comment: "Explanation for why the analytics installation identifier is shown."
        )
        static let analyticsIdentifierCopyButton = String(
            localized: "legal.analyticsIdentifier.copy",
            comment: "Button title to copy the analytics installation identifier."
        )
        static let analyticsIdentifierCopied = String(
            localized: "legal.analyticsIdentifier.copied",
            comment: "Confirmation shown after copying the analytics installation identifier."
        )
        static func legalNoticeMail(_ mailAddress: AttributedString) -> AttributedString {
            AttributedString(
                localized: "legal.legalNotice \(mailAddress)",
                comment: "The legal notice in the legal view. The parameter is the legal e-mail address."
            )
        }

        static func appIconAttribution(_ link: AttributedString) -> AttributedString {
            AttributedString(
                localized: "legal.appIconAttribution \(link)",
                comment: "The attribution for the app icon. The parameter is the attribution link."
            )
        }
    }
}
