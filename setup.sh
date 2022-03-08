#!/bin/bash

# Copyright (c) 2020, the Dart project authors.
#
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

###############################################################################
# Bash script that downloads and does setup for a Dart SDK.                   #
# Takes three params; first listed is the default:                            #
# $1: Dart SDK version/channel: stable|beta|dev|main|<version_string>         #
# $2: OS: Linux|Windows|macOS                                                 #
# $3: ARCH: x64|ia32                                                          #
# $4: FLAVOR: raw|release                                                     #
###############################################################################

# Parse SDK and version args.
SDK="${1:-stable}"
VERSION=
if [[ $SDK == stable || $SDK == beta || $SDK == dev || $SDK == main ]]
then
  CHANNEL=$SDK
  VERSION=latest
else
  CHANNEL=stable
  VERSION=$SDK
  # Derive the channel from the version string
  if [[ "$SDK" == *"dev"* ]]
  then
    CHANNEL=dev
  elif [[ "$SDK" == *"beta"* ]]
  then
    CHANNEL=beta
  elif [[ "$SDK" == *"main"* ]]
  then
    echo -e "::error::Versions cannot be specified for builds from the main channel."
    exit 1
  fi
fi

OS="${2:-Linux}"
ARCH="${3:-x64}"
OS=$(echo "$OS" | awk '{print tolower($0)}')

DEFAULT_FLAVOR=release
if [[ $SDK == main ]]
then
  DEFAULT_FLAVOR=raw
fi

FLAVOR="${4:-$DEFAULT_FLAVOR}"
if ! [[ $FLAVOR == raw || $FLAVOR == release ]]
then
  echo -e "::error::Unrecognized build flavor \"${FLAVOR}\"."
  exit 1
fi

if [[ $SDK == main && $FLAVOR != raw ]]
then
  echo -e "::error::Main channel only supports raw build flavor."
  exit 1
fi

echo "Installing Dart SDK version \"${VERSION}\" from the ${CHANNEL} channel (${FLAVOR}) on ${OS}-${ARCH}"

# Calculate download Url. Based on:
# https://dart.dev/tools/sdk/archive#download-urls
PREFIX="https://storage.googleapis.com/dart-archive/channels"
BUILD="sdk/dartsdk-${OS}-${ARCH}-release.zip"
if [[ $SDK == main ]]
then
  URL="${PREFIX}/be/raw/latest/${BUILD}"
else
  URL="${PREFIX}/${CHANNEL}/${FLAVOR}/${VERSION}/${BUILD}"
fi
echo "Downloading ${URL}..."

# Download installation zip.
curl --connect-timeout 15 --retry 5 --retry-all-errors "$URL" \
  --output "${HOME}/dartsdk.zip"
if [ $? -ne 0 ]; then
  echo -e "::error::Download failed! Please check passed arguments."
  exit 1
fi

# Unzip SDK
unzip -o "${HOME}/dartsdk.zip" -d "${RUNNER_TOOL_CACHE}" > /dev/null
if [ $? -ne 0 ]; then
  echo -e "::error::Unzip failed! Please check passed arguments."
  exit 1
fi
rm "${HOME}/dartsdk.zip"

# Configure pub to use a fixed location.
if [[ $OS == windows ]]
then
  PUBCACHE="${USERPROFILE}\\.pub-cache"
  DART_HOME="${RUNNER_TOOL_CACHE}\\dart-sdk"
else
  PUBCACHE="${HOME}/.pub-cache"
  DART_HOME="${RUNNER_TOOL_CACHE}/dart-sdk"
fi
echo "PUB_CACHE=${PUBCACHE}" >> $GITHUB_ENV
echo "Pub cache set to: ${PUBCACHE}"

# Update paths.
echo "DART_HOME=${DART_HOME}" >> $GITHUB_ENV
echo "${PUBCACHE}/bin" >> $GITHUB_PATH
echo "${RUNNER_TOOL_CACHE}/dart-sdk/bin" >> $GITHUB_PATH

# Report success, and print version.
echo -e "Successfully installed Dart SDK:"
${RUNNER_TOOL_CACHE}/dart-sdk/bin/dart --version
