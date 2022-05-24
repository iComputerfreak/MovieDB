//
//  Strings+Settings.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum Settings {
        static let loadingPlaceholder = String(
            localized: "settings.placeholder.loading",
            comment: "Placeholder text to show while the data is loading"
        )
        static let navBarButtonLegal = String(
            localized: "settings.navBar.button.legal",
            comment: "The 'Legal' button that leads to the legal view in the settings' navigation bar"
        )
        static let importLogNavBarTitle = String(
            localized: "settings.importLog.navBar.title",
            comment: "The navigation bar title for the import log that is being shown after importing media"
        )
        static let importLogNavBarButtonClose = String(
            localized: "settings.importLog.navBar.button.close",
            comment: "The label for the close button in the navigation bar of the settings' import log"
        )
        static let importLogNavBarButtonCopy = String(
            localized: "settings.importLog.navBar.button.copy",
            comment: "The label for the copy button in the navigation bar of the settings' import log"
        )
        
        static let showAdultContentLabel = String(
            localized: "settings.toggle.showAdultContent.label",
            comment: "The label of the toggle in the settings that allows the user to specify whether the search results and library should include adult content"
        )
        static let buyProLabel = String(
            localized: "settings.actions.buyPro.label",
            comment: "The label for the button in the settings to buy the pro version of the app"
        )
        static let reloadMediaLabel = String(
            localized: "settings.actions.reloadMedia.label",
            comment: "The label for the 'reload media' action in the settings view"
        )
        static let updateMediaLabel = String(
            localized: "settings.actions.updateMedia.label",
            comment: "The label for the 'update media' action in the settings view"
        )
        static let resetLibraryLabel = String(
            localized: "settings.actions.resetLibrary.label",
            comment: "The label for the 'reset library' action in the settings view"
        )
        static let resetTagsLabel = String(
            localized: "settings.actions.resetTags.label",
            comment: "The label for the 'reset tags' action in the settings view"
        )
        
        static func versionFooter(_ version: String) -> String {
            String(
                localized: "settings.footer.version \(version)",
                comment: "The version information at the bottom of the settings page"
            )
        }
        static let importMediaLabel = String(
            localized: "settings.actions.importMedia.label",
            comment: "The label for the 'import media' action in the settings view"
        )
        static let exportMediaLabel = String(
            localized: "settings.actions.exportMedia.label",
            comment: "The label for the 'export media' action in the settings view"
        )
        static let importTagsLabel = String(
            localized: "settings.actions.importTags.label",
            comment: "The label for the 'import tags' action in the settings view"
        )
        static let exportTagsLabel = String(
            localized: "settings.actions.exportTags.label",
            comment: "The label for the 'export tags' action in the settings view"
        )
        static func loadingTextMediaImport(_ progress: Int) -> String {
            String(
                localized: "settings.import.progressText \(progress)",
                comment: "The label of the overlay progress view that shows the user how many media objects have been imported already"
            )
        }
        
        static let languageNavBarTitle = String(
            localized: "settings.language.navBar.title",
            comment: "The navigation bar title for the language picker in the settings"
        )
        static let languagePickerLoadingText = String(
            localized: "settings.languagePicker.loadingText",
            comment: "Placeholder text to display while loading the available languages in the settings"
        )
        static let regionNavBarTitle = String(
            localized: "settings.region.navBar.title",
            comment: "The navigation bar title for the region picker in the settings"
        )
        
        enum Alert {
            static let reloadCompleteTitle = String(
                localized: "settings.alert.reloadCompleted.title",
                comment: "Title of the alert informing the user that the media reload is completed"
            )
            static let reloadCompleteMessage = String(
                localized: "settings.alert.reloadCompleted.message",
                comment: "Message of the alert informing the user that the media reload is completed"
            )
            static let reloadErrorTitle = String(
                localized: "settings.alert.errorReloadingLibrary.title",
                comment: "Title of an alert informing the user about an error while reloading the library"
            )
            static let reloadLibraryTitle = String(
                localized: "settings.alert.reloadLibrary.title",
                comment: "Title of an alert asking the user for confirmation to reload the library"
            )
            static let reloadLibraryMessage = String(
                localized: "settings.alert.reloadLibrary.message",
                comment: "Message of an alert asking the user for confirmation to reload the library after changing the language or region"
            )
            static let updateMediaTitle = String(
                localized: "settings.alert.updateMediaComplete.title",
                comment: "Title of an alert informing the user that the library update is completed"
            )
            static func updateMediaMessage(_ count: Int) -> String {
                String(
                    localized: "settings.alert.updateMediaComplete.message \(count)",
                    comment: "Message of an alert informing the user how many media objects have been updated. The argument is the count of updated objects"
                )
            }
            static let libraryUpdateErrorTitle = String(
                localized: "settings.alert.libraryUpdateError.title",
                comment: "Title of an alert informing the user of an error while updating the library"
            )
            static let resetLibraryConfirmTitle = String(
                localized: "settings.alert.resetLibrary.title",
                comment: "Title of an alert asking the user for confirmation to reset the library"
            )
            static let resetLibraryConfirmMessage = String(
                localized: "settings.alert.resetLibrary.message",
                comment: "Message of an alert asking the user for confirmation to reset the library"
            )
            static let resetLibraryConfirmButtonDelete = String(
                localized: "settings.alert.resetLibrary.button.delete",
                comment: "Button to confirm the library reset"
            )
            static let resetLibraryErrorTitle = String(
                localized: "settings.alert.resetLibraryError.title",
                comment: "Title of an alert informing the user of an error while resetting the library"
            )
            static let resetTagsConfirmTitle = String(
                localized: "settings.alert.resetTags.title",
                comment: "Title of an alert asking the user to confirm resettings the tags"
            )
            static let resetTagsConfirmMessage = String(
                localized: "settings.alert.resetTags.message",
                comment: "Message of an alert asking the user to confirm resetting the tags"
            )
            static let resetTagsConfirmButtonDelete = String(
                localized: "settings.alert.resetTags.button.delete",
                comment: "Button of an alert, confirming the tag reset"
            )
            static let resetTagsErrorTitle = String(
                localized: "settings.alert.resetTagsError.title",
                comment: "Title of an alert informing the user of an error during tag reset"
            )
            static let importMediaConfirmTitle = String(
                localized: "settings.alert.importMedia.title",
                comment: "Title of an alert asking the user to confirm the import"
            )
            static func importMediaConfirmMessage(_ count: Int) -> String {
                String(
                    localized: "settings.alert.importMedia.message \(count)",
                    comment: "Message of an alert asking the user to confirm the import. The argument is the count of media objects to import."
                )
            }
            static let importMediaConfirmButtonUndo = String(
                localized: "settings.alert.importMedia.button.undo",
                comment: "Button to undo the media import"
            )
            static let importTagsConfirmTitle = String(
                localized: "settings.alert.importTags.title",
                comment: "Title of an alert asking the user to confirm importing the tags"
            )
            static func importTagsConfirmMessage(_ count: Int) -> String {
                String(
                    localized: "settings.alert.importTags.message \(count)",
                    comment: "Message of an alert asking the user to confirm importing the tags. The argument is the count of tags to import."
                )
            }
            static let importTagsErrorTitle = String(
                localized: "settings.alert.tagImportError.title",
                comment: "Title of an alert informing the user of an error during tag import"
            )
            static let genericImportErrorTitle = String(
                localized: "settings.alert.genericImportError.title",
                comment: "Title of an error informing the user about an error during import"
            )
            static let genericExportErrorTitle = String(
                localized: "settings.alert.genericExportError.title",
                comment: "Title of an alert informing the user about an error during export"
            )
            static let genericExportErrorMessage = String(
                localized: "settings.alert.genericExportError.message",
                comment: "Message of an alert informing the user about an error during export"
            )
            static let errorLoadingLanguagesTitle = String(
                localized: "settings.languagePicker.alert.errorLoading.title",
                comment: "Title of an alert informing the user about an error while reloading the available languages"
            )
        }
        
        enum ProgressView {
            static let reloadLibrary = String(
                localized: "settings.progressText.reloadLibrary",
                comment: "The label of the progress indicator that is shown in the settings when the library is reloading all media objects"
            )
            static let updateMedia = String(
                localized: "settings.progressText.updatingMediaObjects",
                comment: "The label for the progress view, displayed while updating the media objects"
            )
            static let resetLibrary = String(
                localized: "settings.progressText.resetLibrary",
                comment: "The label for the progress view, displayed while resetting the library"
            )
            static let resetTags = String(
                localized: "settings.progressText.resetTags",
                comment: "The label for the progress view, displayed while resetting the tags"
            )
        }
    }
}
