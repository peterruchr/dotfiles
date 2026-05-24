#!/bin/bash

MONITOR_NAME="DP-3"

if kscreen-doctor -j | jq -e ".outputs[] | select(.name == \"$MONITOR_NAME\") | .hdr" >/dev/null; then
    # The JSON value is 'true' -> Switch to SDR Profile
    kscreen-doctor output."$MONITOR_NAME".hdr.disable output."$MONITOR_NAME".wcg.disable output."$MONITOR_NAME".brightness.25
else
    # The JSON value is 'false' -> Switch to HDR Profile
    kscreen-doctor output."$MONITOR_NAME".hdr.enable output."$MONITOR_NAME".wcg.enable output."$MONITOR_NAME".brightness.100
fi
