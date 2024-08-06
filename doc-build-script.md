This script is used to build the DocC documentation in a static HTML format suitable for hosting on
GitHub Pages at https://russell-archer.github.io/SKHelper/documentation/skhelper/.

Run the script from Terminal in the root of the SKHelper project directory.

swift package --allow-writing-to-directory docs generate-documentation --target SKHelper --disable-indexing --transform-for-static-hosting --hosting-base-path SKHelper --output-path docs
