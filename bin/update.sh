#!/bin/bash

# Get current working dir.
PWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Test version argument.
if [ -z "$1" ]; then
  echo "A release version must be supplied (e.g. 7.0.1)."

  exit 1
fi

# Remove previous src dir.
find src -depth 1 ! -iregex 'src/index.js' | xargs rm -rf

# Prepare a new branch for this update.
git checkout -b support/update-libphonenumber-${1//\./\-}

# Download the requested tagged release.
echo "Downloading release $1..."

curl -L -s https://github.com/googlei18n/libphonenumber/archive/libphonenumber-$1.tar.gz | tar -xf - --strip-components=4 -C $PWD/../src --include='*javascript/i18n/phonenumbers*'

# Apply custom patch to convert strings to proper errors.
echo "Applying patches..."

curl -L -s https://patch-diff.githubusercontent.com/raw/googlei18n/libphonenumber/pull/690.patch | git apply -p4 --directory=src

# Build distribution files.
npm run build

echo "Done!"

# Add the modified files to git.
git add $PWD/../src/
git add $PWD/../dist/

# Commit with the standard message.
git commit -m "Update libphonenumber@$1"
