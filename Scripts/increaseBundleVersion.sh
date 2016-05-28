plist_file=$SRCROOT/MacKey/Info.plist
short_version=$( /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_file" )
echo $short_version
build_number=1
build_number_file="$SRCROOT/build_number"
[ -e "$build_number_file" ] && build_number=$( cat "$build_number_file" )
new_build_number=$((build_number+1))
bundleID="$short_version.$new_build_number"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundleID" "$plist_file"

echo $new_build_number > "$build_number_file"
