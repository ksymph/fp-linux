#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_PATH="$(readlink -f "$SCRIPT_DIR/../BrowserPlugins/Flash")"
export MOZ_PLUGIN_PATH="$PLUGIN_PATH"
exec "$SCRIPT_DIR/flashpointnavigator" "$@"
