#!/bin/bash

set -e

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
screenshots_dir="$root_dir/fastlane/screenshots"
studio_dir="$root_dir/Assets/App Store Screenshots/AppStoreScreenshots.screenshotstudio"

source_locales=("en-US" "de-DE" "fr-FR" "es-ES" "it-IT" "ja-JP" "ko-KR" "pl-PL" "pt-BR")
studio_locales=("en-US" "de-DE" "fr-FR" "es-ES" "it" "ja" "ko" "pl" "pt-BR")

iphone_screens=("01_Library" "03_Detail" "05_Lists" "07_ListConfiguration" "08_Settings")
ipad_screens=("01_Detail" "04_WList" "05_ListConfiguration" "06_Settings")

for locale_index in "${!source_locales[@]}"; do
    source_locale="${source_locales[$locale_index]}"
    studio_locale="${studio_locales[$locale_index]}"

    for screen_index in "${!iphone_screens[@]}"; do
        source="$screenshots_dir/$source_locale/iPhone 17 Pro Max-${iphone_screens[$screen_index]}.png"
        destination="$studio_dir/iphone/images/${studio_locale}_${screen_index}.jpeg"
        sips -s format jpeg "$source" --out "$destination" >/dev/null
    done

    for screen_index in "${!ipad_screens[@]}"; do
        source="$screenshots_dir/$source_locale/iPad Pro 13-inch (M5)-${ipad_screens[$screen_index]}.png"
        destination="$studio_dir/ipad/images/${studio_locale}_${screen_index}.jpeg"
        sips -s format jpeg "$source" --out "$destination" >/dev/null
    done
done

echo "Updated ScreenshotStudio images."
