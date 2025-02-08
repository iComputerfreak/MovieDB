//
//  Strings+Generic.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum Generic {
        static let alertErrorTitle = String(
            localized: "generic.alert.title.error",
            comment: "Title of an alert informing the user about an error"
        )
        static let alertButtonOk = String(
            localized: "generic.alert.button.okay",
            comment: "Okay button to dismiss an alert popup"
        )
        static let alertButtonCancel = String(
            localized: "generic.alert.button.cancel",
            comment: "Cancel button to dismiss an alert popup"
        )
        static let alertButtonYes = String(
            localized: "generic.alert.button.yes",
            comment: "Yes button to confirm an alert popup"
        )
        static let alertButtonNo = String(
            localized: "generic.alert.button.no",
            comment: "Okay button to deny an alert popup"
        )
        static let pickerValueYes = String(
            localized: "generic.picker.value.yes",
            comment: "An option in a picker view"
        )
        static let pickerValueNo = String(
            localized: "generic.picker.value.no",
            comment: "An option in a picker view"
        )
        static let alertDeleteTitle = String(
            localized: "generic.alert.delete.title",
            comment: "The title of the delete alert"
        )
        static let alertDeleteMessage = String(
            localized: "generic.alert.delete.message",
            comment: "The message of the delete alert"
        )
        static let alertDeleteButtonTitle = String(
            localized: "generic.alert.delete.buttonTitle",
            comment: "The title of the delete button on the delete alert"
        )
        static let navBarLoadingTitle = String(
            localized: "generic.navBar.loadingTitle",
            comment: "The navigation bar title for a view that is still loading"
        )
        static let pickerNavBarButtonReset = String(
            localized: "generic.picker.navBar.button.reset",
            comment: "The navigation bar button label for the button that resets the currently visible range editing view"
        )
        static let pickerRangeFromLabel = String(
            localized: "generic.picker.range.from",
            comment: "A range editing label that prefixes the actual value that is currently selected for the lower bound of the range."
        )
        static let pickerRangeToLabel = String(
            localized: "generic.picker.range.to",
            comment: "A range editing label that prefixes the actual value that is currently selected for the upper bound of the range."
        )
        static func pickerRangeFromValueLabel(_ value: String) -> String {
            String(
                localized: "generic.picker.range.from.value \(value)",
                comment: "A range editing label that describes the actual value that is currently selected for the lower bound of the range. The parameter is the value."
            )
        }

        static func pickerRangeToValueLabel(_ value: String) -> String {
            String(
                localized: "generic.picker.range.to.value \(value)",
                comment: "A range editing label that describes the actual value that is currently selected for the upper bound of the range. The parameter is the value."
            )
        }

        static func pickerMultipleValuesLabel(_ count: Int) -> String {
            String(
                localized: "generic.picker.multipleValues \(count)",
                comment: "A picker label that indicates that there are currently multiple values selected. The parameter is the count of selected values."
            )
        }

        static let pickerNoValuesLabel = String(
            localized: "generic.picker.noValues",
            comment: "The label displayed by a picker when there are no possible values to pick from"
        )
        static let errorText = String(
            localized: "generic.errorText",
            comment: "Generic error text to display when a view failed to load"
        )
        static let unknown = String(
            localized: "generic.unknown",
            comment: "A generic string describing that a value or some property is unknown"
        )
        static let loadingText = String(
            localized: "generic.loadingText",
            comment: "A generic 'Loading...' string, displayed with a progress view"
        )
        static let editButtonLabelDone = String(
            localized: "generic.editButtonDone",
            comment: "The edit button label displayed while in editing mode"
        )
        static let editButtonLabelEdit = String(
            localized: "generic.editButtonEdit",
            comment: "The edit button label displayed while not in editing mode"
        )
        static let dismissViewDone = String(
            localized: "generic.dismissViewDone",
            comment: "The done button to dismiss a view (e.g. a popup or sheet view)"
        )
        static let multipleObjectsSelected = String(
            localized: "generic.multipleObjectsSelected",
            comment: "A text that is displayed when there are multiple objects selected, but the user is supposed to only select one"
        )
        static let retryLoading = String(
            localized: "generic.retryLoading",
            comment: "A button label indicating an action to retry loading something"
        )
        static let never = String(
            localized: "generic.never",
            comment: "A string indicating that something did never happen"
        )
        static let selectAll = String(
            localized: "generic.selectAll",
            comment: "A button label to select all items in a list"
        )
        static let selectNone = String(
            localized: "generic.selectNone",
            comment: "A button label to deselect all items in a list"
        )
    }
}
