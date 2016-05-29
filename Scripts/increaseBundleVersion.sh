set -ex

plist_file=$SRCROOT/MacKey/Info.plist
short_version=$( /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_file" )
old_bundle_version=$( /usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$plist_file" )

build_number=1
[ -z "$old_bundle_version" ] || build_number=$( echo "$old_bundle_version" | grep -Eo "[^.]*$" )
new_build_number=$((build_number+1))
new_bundle_version="$short_version.$new_build_number"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_bundle_version" "$plist_file"
