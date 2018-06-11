#!/bin/bash

set -ev

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
	DIR="$(pwd)"
    cd ..
	export SWIFT_VERSION=swift-4.1.2-RELEASE # https://swift.org/builds/swift-4.1.2-release/ubuntu1404/swift-4.1.2-RELEASE/swift-4.1.2-RELEASE-ubuntu14.04.tar.gz
	wget https://swift.org/builds/${SWIFT_VERSION}/ubuntu1404/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu14.04.tar.gz
	tar xzf $SWIFT_VERSION-ubuntu14.04.tar.gz
	export PATH="${PWD}/${SWIFT_VERSION}-ubuntu14.04/usr/bin:${PATH}"
	cd "$DIR"
else
	export SWIFT_VERSION=swift-4.1.2-RELEASE # https://swift.org/builds/swift-4.1.2-release/xcode/swift-4.1.2-RELEASE/swift-4.1.2-RELEASE-osx.pkg
	curl -O https://swift.org/builds/${SWIFT_VERSION}/xcode/${SWIFT_VERSION}/${SWIFT_VERSION}-osx.pkg
	sudo installer -pkg ${SWIFT_VERSION}-osx.pkg -target /
	export TOOLCHAINS=swift
fi
