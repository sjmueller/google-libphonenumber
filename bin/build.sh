#!/bin/bash

# Clean previous distribution build.
rm -rf dist/*

# Test if online compilation should be used.
if [ "${ONLINE:-true}" == "true" ]; then
  echo "Compiling using Google Closure Service..."

  curl --silent \
    --request POST \
    --data-ascii output_format=text \
    --data-ascii output_info=compiled_code \
    --data-ascii use_closure_library=true \
    --data-ascii compilation_level=SIMPLE_OPTIMIZATIONS \
    --data-ascii formatting=PRETTY_PRINT \
    --data-urlencode js_code@src/index.js \
    --data-urlencode js_code@src/asyoutypeformatter.js \
    --data-urlencode js_code@src/phonenumberutil.js \
    --data-urlencode js_code@src/phonemetadata.pb.js \
    --data-urlencode js_code@src/metadata.js \
    --data-urlencode js_code@src/phonenumber.pb.js \
    --output dist/libphonenumber.js \
    http://closure-compiler.appspot.com/compile
else
  echo "Compiling locally..."

  ant build
fi

echo "Browserifying..."

mkdir -p dist/browser

./node_modules/.bin/browserify dist/libphonenumber.js --standalone libphonenumber --no-browser-field --outfile dist/browser/libphonenumber.js

echo "Minifying..."

./node_modules/.bin/browserify dist/libphonenumber.js --standalone libphonenumber --plugin \[minifyify --no-map\] --outfile dist/browser/libphonenumber.min.js

echo "Build completed!"
