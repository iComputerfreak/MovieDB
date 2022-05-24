//
//  Strings+Generic.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

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
    }
}
