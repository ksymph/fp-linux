app-id: org.flashpointarchive.infinity
runtime: org.freedesktop.Platform
runtime-version: '24.08'
sdk: org.freedesktop.Sdk
base: org.electronjs.Electron2.BaseApp
base-version: '24.08'
sdk-extensions:
  - org.freedesktop.Sdk.Extension.node24
  - org.freedesktop.Sdk.Extension.php83
  - org.freedesktop.Sdk.Extension.golang
command: flashpoint-wrapper.sh

finish-args:
  - --socket=x11
  - --share=ipc
  - --device=dri
  - --share=network

modules:
  # Add GTK2 via shared-modules
  - gtk2/gtk2.json

  # Launcher module (unchanged)
  - name: launcher
    buildsystem: simple
    build-options:
      append-path: /usr/lib/sdk/node24/bin
      env:
        npm_config_cache: /run/build/launcher/npm-cache
      build-args:
        - --share=network
    build-commands:
      - patch -p1 < env-config-path.patch
      - npm install
      - npm run build
      - mkdir -p /app/launcher
      - cp -r . /app/launcher
    sources:
      - type: git
        url: https://github.com/FlashpointProject/launcher.git
        branch: develop
      - type: file
        path: env-config-path.patch

  # fp-linux module – now using local source and selective copy
  - name: fp-linux
    buildsystem: simple
    build-commands:
      - mkdir -p /app/share/fp-linux
      - cp .preferences.defaults.json /app/share/fp-linux/
      - cp execs.json /app/share/fp-linux/
      - cp services.json /app/share/fp-linux/
      - cp flash32 /app/share/fp-linux/
      - cp libflashplayer.so /app/share/fp-linux/
      - cp mozilla.cfg /app/share/fp-linux/
      - cp start-fpnavigator.sh /app/share/fp-linux/
      # Copy any additional files (e.g., README) if present
      - cp README* /app/share/fp-linux/ 2>/dev/null || true
    sources:
      - type: dir
        path: .

  # Gameserver module (unchanged)
  - name: gameserver
    buildsystem: simple
    build-options:
      append-path: /usr/lib/sdk/golang/bin
      env:
        GOPATH: /run/build/gameserver/go
      build-args:
        - --share=network
    build-commands:
      - go mod download
      - go build -o FlashpointGameServer
      - install -Dm755 FlashpointGameServer /app/share/gameserver/FlashpointGameServer
      - install -Dm644 proxySettings.json /app/share/gameserver/proxySettings.json
      - chmod -R u+w /run/build/gameserver/go
    sources:
      - type: git
        url: https://github.com/FlashpointProject/FlashpointGameServer.git
        disable-submodules: false
        branch: main

  # Core components (unchanged)
  - name: core-configuration
    buildsystem: simple
    build-commands:
      - mkdir -p /app/share/component/
      - cp -r * /app/share/component/
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/core/configuration.git
        branch: main

  - name: core-legacy-router
    buildsystem: simple
    build-commands:
      - cp -r * /app/share/component/
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/core/legacy-router.git
        branch: main

  - name: core-credits
    buildsystem: simple
    build-commands:
      - mkdir -p /app/share/component/Data
      - cp -r * /app/share/component/Data/
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/core/credits.git
        branch: main

  # Logo sets (unchanged)
  - name: logo-oldschool
    buildsystem: simple
    build-commands:
      - mkdir -p "/app/share/component/Data/LogoSets/Old School"
      - cp -r * "/app/share/component/Data/LogoSets/Old School"
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/logo-sets/oldschool.git

  - name: logo-adobeblue
    buildsystem: simple
    build-commands:
      - mkdir -p "/app/share/component/Data/LogoSets/Adobe Blue"
      - cp -r * "/app/share/component/Data/LogoSets/Adobe Blue"
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/logo-sets/adobeblue.git

  - name: logo-macintosh
    buildsystem: simple
    build-commands:
      - mkdir -p "/app/share/component/Data/LogoSets/Macintosh"
      - cp -r * "/app/share/component/Data/LogoSets/Macintosh"
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/logo-sets/macintosh.git

  - name: logo-millennium
    buildsystem: simple
    build-commands:
      - mkdir -p "/app/share/component/Data/LogoSets/Millennium"
      - cp -r * "/app/share/component/Data/LogoSets/Millennium"
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/logo-sets/millennium.git

  - name: logo-default
    buildsystem: simple
    build-commands:
      - mkdir -p /app/share/component/Data/Logos
      - cp -r * /app/share/component/Data/Logos
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/core/logos.git
        branch: main

  # Flash support (unchanged)
  - name: flash-support
    buildsystem: simple
    build-commands:
      - mkdir -p /app/share/component/FPSoftware
      - cp -r * /app/share/component/FPSoftware/
    sources:
      - type: git
        url: https://gitlab.unstable.life/flashpoint/components/support-packs/flash.git

  # Wrapper script (unchanged)
  - name: wrapper
    buildsystem: simple
    build-commands:
      - install -Dm755 flashpoint-wrapper.sh /app/bin/flashpoint-wrapper.sh
    sources:
      - type: file
        path: flashpoint-wrapper.sh
