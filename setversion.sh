#!/bin/bash

# Read version from version.txt
read -r NEW_VERSION < version.txt

echo "Updating package versions to ${NEW_VERSION}."

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS requires an empty string argument after -i to edit in place without backup
  sed -i '' "s/^const String telemetryClientVersion = .*$/const String telemetryClientVersion = \"${NEW_VERSION}\";/g" "lib/versions.dart"
  sed -i '' "s/^version: .*/version: ${NEW_VERSION}/g" "pubspec.yaml"
else
  # Linux
  sed -i "/const String telemetryClientVersion =/c\const String telemetryClientVersion = \"${NEW_VERSION}\";" "lib/versions.dart"
  sed -i "s/^version: .*/version: ${NEW_VERSION}/g" "pubspec.yaml"
fi

echo "Version updated to ${NEW_VERSION}."