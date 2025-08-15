#!/bin/bash

# Script to collect all the device information from the Garmin Connect IQ SDK Devices folder
# and present it in a human-readable CSV format.

# Usage Mac :
# ./makedevices.sh ~/Library/Application\ Support/Garmin/ConnectIQ/Devices/


# Collect all compiler.json files from subdirectories and combines them into a single devices.json file.
jq --slurp '.' "${1}"*/compiler.json  > devices.json

# Convert the json file to csv
(echo "deviceFamily,deviceId,displayType,connectIQVersion(s),audioMemoryLimit,backgroundMemoryLimit,datafieldMemoryLimit,glanceMemoryLimit,watchAppMemoryLimit,watchFaceMemoryLimit,partNumber(s),displayName"; \
jq -r '.[] | [
    .deviceFamily,
    .deviceId,
    .displayType,
    ([.partNumbers[]? | select(.connectIQVersion) | .connectIQVersion] | unique | join(" ") // "-"),
    (.appTypes[]? | select(.type=="audioContentProvider") | .memoryLimit) // "-",
    (.appTypes[]? | select(.type=="background") | .memoryLimit) // "-",
    (.appTypes[]? | select(.type=="datafield") | .memoryLimit) // "-",
    (.appTypes[]? | select(.type=="glance") | .memoryLimit) // "-",
    (.appTypes[]? | select(.type=="watchApp") | .memoryLimit) // "-",
    (.appTypes[]? | select(.type=="watchFace") | .memoryLimit) // "-",
    ([.partNumbers[]? | .number] | unique | join(" ") // "-"),
    .displayName
] | @csv' devices.json
) > devices.csv
