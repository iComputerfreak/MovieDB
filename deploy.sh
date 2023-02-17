#!/bin/zsh

set -e

function yes_or_no {
	vared -p "$* [Yn] " -c yn
	if [[ -z "$yn" ]]; then
		return 0
	fi
	case $yn in
		[Yy]*) return 0 ;;  
		[Nn]*) return 1 ;;
	esac
}

project_name="Movie DB"

# Go into project directory
cd $(dirname $0)
cd "$project_name"

current_version=$(/usr/libexec/PlistBuddy -c "print :CFBundleVersion" Info.plist)
echo "Current version: $current_version"
vared -p "What version would you like to update to?: " -c new_version

if [[ -z "$new_version" ]]; then
	exit 0
fi

# Update the app version
/usr/libexec/PlistBuddy -c "set :CFBundleVersion $new_version" Info.plist
/usr/libexec/PlistBuddy -c "set :CFBundleShortVersionString $new_version" Info.plist

new_version=$(/usr/libexec/PlistBuddy -c "print :CFBundleVersion" Info.plist)

if ! yes_or_no "Do you want to push version $new_version to GitHub and create a release?"; then
	exit 0
fi

echo "Tagging and pushing changes..."
git add Info.plist
git commit -m "Bumped version to $new_version"
git tag "$new_version"
git push
git push --tags

echo "Creating GitHub release..."
gh auth login
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/iComputerfreak/MovieDB/releases \
  -f tag_name="$new_version" \
  -f name="Version $new_version" \
  -F generate_release_notes=false

echo "Version $new_version created."
