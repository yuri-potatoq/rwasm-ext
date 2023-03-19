#!/bin/sh

print "removing old build artefact"
rm -rf pkg


wasm-pack build --target=no-modules || exit 1

print "moving pkg stuff"
cp -r ./_pkg/** ./pkg
