#!/bin/zsh

# This script is used to build DocC documentation for the SKHelper package in a static HTML format suitable for hosting on
# GitHub Pages at https://russell-archer.github.io/SKHelper/documentation/skhelper/
#
# Run this script from the root of the SKHelper project directory.
#
# Note that you can also build DocC documentation from Xcode by selecting Product > Build Documentation.
# 

echo "Build DocC documentation for the SKHelper package."
echo "Press [Return] to continue or ^C to abort..."
read -n -s
swift package --allow-writing-to-directory docs generate-documentation --target SKHelper --disable-indexing --transform-for-static-hosting --hosting-base-path SKHelper --output-path docs
