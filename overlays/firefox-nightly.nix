pin: final: prev: let
  inherit (prev) lib;

  linked = with final; [
    alsa-lib
    at-spi2-core
    cairo
    dbus
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    pango
    stdenv.cc.cc
  ];

  dlopened = with final; [
    cups
    curl
    ffmpeg-release
    libdrm
    libgbm
    libglvnd
    libnotify
    libpulseaudio
    libva
    pciutils
    pipewire
    systemdLibs
    vulkan-loader
  ];

  deps = final.symlinkJoin {
    name = "firefox-nightly-deps";
    paths = map lib.getLib (linked ++ dlopened);
  };

  schemas = map final.glib.getSchemaPath [final.gtk3 final.gsettings-desktop-schemas];
in {
  firefox-nightly = final.stdenvNoCC.mkDerivation {
    pname = "firefox-nightly";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook final.patchelfUnstable final.copyDesktopItems];
    buildInputs = [deps];
    appendRunpaths = ["${deps}/lib"];
    patchelfFlags = ["--no-clobber-old-sections"];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib $out/share/glib-2.0/schemas
      cp -r . $out/lib/firefox
      touch $out/lib/firefox/is-packaged-app
      ln -s ../lib/firefox/firefox $out/bin/firefox-nightly
      for n in 16 32 48 64 128; do
        install -Dm644 browser/chrome/icons/default/default$n.png $out/share/icons/hicolor/''${n}x$n/apps/firefox-nightly.png
      done
      mkdir schemas
      cp ${lib.concatMapStringsSep " " (s: "${s}/*.xml") schemas} schemas
      ${lib.getExe' final.buildPackages.glib.dev "glib-compile-schemas"} --targetdir=$out/share/glib-2.0/schemas schemas
      runHook postInstall
    '';

    desktopItems = [
      (final.makeDesktopItem {
        name = "firefox-nightly";
        desktopName = "Firefox Nightly";
        genericName = "Web Browser";
        exec = "firefox-nightly %U";
        icon = "firefox-nightly";
        startupWMClass = "firefox-nightly";
        categories = ["Network" "WebBrowser"];
        mimeTypes = [
          "application/xhtml+xml"
          "text/html"
          "text/xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        actions = {
          new-window = {
            name = "New Window";
            exec = "firefox-nightly --new-window %U";
          };
          new-private-window = {
            name = "New Private Window";
            exec = "firefox-nightly --private-window %U";
          };
        };
      })
    ];

    doInstallCheck = true;
    installCheckPhase = ''
      grep -qaF "$(patchelf --print-soname ${deps}/lib/libavcodec.so)" $out/lib/firefox/libxul.so
    '';

    meta.mainProgram = "firefox-nightly";
  };
}
