#!/bin/sh
# Wrapper for Flashpoint Infinity Flatpak

set -e

# Writable data directory (persisted via --persist=data)
DATA_DIR="${XDG_DATA_HOME:-$HOME/.var/app/org.flashpointarchive.infinity/data}"
mkdir -p "$DATA_DIR"

# Set environment variable to redirect config.json to the data directory
export FLASHPOINT_CONFIG_PATH="$DATA_DIR/config.json"

# ----- Write launcher config.json (only if it doesn't exist) -----
if [ ! -f "$DATA_DIR/config.json" ]; then
    cat > "$DATA_DIR/config.json" <<EOF
{
  "flashpointPath": "$DATA_DIR",
  "useCustomTitlebar": false,
  "startServer": true,
  "backPortMin": 12001,
  "backPortMax": 12100,
  "imagesPortMin": 12101,
  "imagesPortMax": 12200,
  "logsBaseUrl": "https://logs.unstable.life/",
  "updatesEnabled": true,
  "gotdUrl": "https://download.unstable.life/gotd.json",
  "gotdShowAll": false,
  "middlewareOverridePath": "Legacy/middleware_overrides/"
}
EOF
fi

cp -rf /app/share/component "$DATA_DIR" 2>/dev/null || true

# ----- Copy Linux‑specific files from fp-linux -----
# .preferences.defaults.json (root of data dir)
cp -f /app/share/fp-linux/.preferences.defaults.json "$DATA_DIR/" 2>/dev/null || true

# execs.json and services.json go into Data/
mkdir -p "$DATA_DIR/Data"
cp -f /app/share/fp-linux/execs.json "$DATA_DIR/Data/" 2>/dev/null || true
cp -f /app/share/fp-linux/services.json "$DATA_DIR/Data/" 2>/dev/null || true

# Flash Player executable
mkdir -p "$DATA_DIR/FPSoftware/Flash"
cp -f /app/share/fp-linux/flash32 "$DATA_DIR/FPSoftware/Flash/" 2>/dev/null || true
chmod +x "$DATA_DIR/FPSoftware/Flash/flash32" 2>/dev/null || true

# Browser plugin and navigator config
mkdir -p "$DATA_DIR/FPSoftware/BrowserPlugins/Flash"
cp -f /app/share/fp-linux/libflashplayer.so "$DATA_DIR/FPSoftware/BrowserPlugins/Flash/" 2>/dev/null || true

mkdir -p "$DATA_DIR/FPSoftware/flashpointnavigator"
cp -f /app/share/fp-linux/mozilla.cfg "$DATA_DIR/FPSoftware/flashpointnavigator/" 2>/dev/null || true
cp -f /app/share/fp-linux/start-fpnavigator.sh "$DATA_DIR/FPSoftware/flashpointnavigator/" 2>/dev/null || true
chmod +x "$DATA_DIR/FPSoftware/flashpointnavigator/start-fpnavigator.sh" 2>/dev/null || true

# ----- Copy fpnavigator (browser) files -----
if [ -d /app/share/fpnavigator ]; then
    mkdir -p "$DATA_DIR/FPSoftware/flashpointnavigator"
    cp -rf /app/share/fpnavigator/* "$DATA_DIR/FPSoftware/flashpointnavigator/" 2>/dev/null || true
fi

# ----- Copy game server binary and config -----
mkdir -p "$DATA_DIR/Server"
cp -f /app/share/gameserver/FlashpointGameServer "$DATA_DIR/Server/" 2>/dev/null || true
cp -f /app/share/gameserver/proxySettings.json "$DATA_DIR/Server/" 2>/dev/null || true
chmod +x "$DATA_DIR/Server/FlashpointGameServer" 2>/dev/null || true

# ----- Launch the launcher from its own directory (required) -----
cd /app/launcher
exec zypak-wrapper /app/launcher/node_modules/electron/dist/electron /app/launcher "$@"
