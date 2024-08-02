#!/bin/bash

# Read version from version.txt
read -r NEW_VERSION < version.txt

echo "Updating package versions to ${NEW_VERSION}."

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS requires an empty string argument after -i to edit in place without backup
  sed -i '' "s/^const String telemetryClientVersion = .*$/const String telemetryClientVersion = \"${NEW_VERSION}\";/g" "lib/src/versions.dart"
  sed -i '' "s/^version: .*/version: ${NEW_VERSION}/g" "pubspec.yaml"
else
  # Linux
  sed -i "/const String telemetryClientVersion =/c\const String telemetryClientVersion = \"${NEW_VERSION}\";" "lib/src/versions.dart"
  sed -i "s/^version: .*/version: ${NEW_VERSION}/g" "pubspec.yaml"
fi

# pub.dev requires that the CHANGELOG includes the version number.
# Make sure the CHANGELOG includes this version number. This is optional because it may have been updated manually by another action.
if ! grep -q "## ${NEW_VERSION}" CHANGELOG.md; then
  echo "CHANGELOG.md does not include a section for version ${NEW_VERSION}."
  echo -e "## ${NEW_VERSION}\n\n- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/${NEW_VERSION}\n\n" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
fi

echo "Version updated to ${NEW_VERSION}."