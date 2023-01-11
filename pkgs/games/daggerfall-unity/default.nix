{ stdenv
, lib
, buildFHSUserEnv
, fetchzip
, makeDesktopItem
, alsa-lib
, libglvnd
, libpulseaudio
, vulkan-headers
, vulkan-loader
, xorg
, zlib
 }:

# TODO: Vulkan? Vulkan is only selected when `-force-vulkan` is enabled, but we don't know if a nixos config supports Vulkan.....
# TODO: Is vulkan-headers required for using `-force-vulkan`?
# TODO: Darwin version? Impossible due to buildFSHUserEnv?
# TODO: Mods? Do they work?

let
  daggerfall-unity-unwrapped = stdenv.mkDerivation rec {
    pname = "daggerfall-unity";
    version = "0.14.5-beta";

    src = fetchzip {
      url = "https://github.com/Interkarma/daggerfall-unity/releases/download/v${version}/dfu_linux_64bit-v${version}.zip";
      hash = "sha256-8OXIzkyVZgSbDtcB+BreFSHNJqTKP2kNRWgibWwwZtc=";
      stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/libexec
      mkdir -p $out/share/icons/hicolor/128x128/apps
      cp -r $src/* $out/libexec
      cp $src/DaggerfallUnity_Data/Resources/UnityPlayer.png \
        $out/share/icons/hicolor/128x128/apps/DaggerfallUnity128.png
    '';
  };

  desktopItem = makeDesktopItem rec {
    name = "daggerfall-unity";
    exec = "daggerfall-unity";
    icon = "DaggerfallUnity128";
    desktopName = "Daggerfall Unity";
    comment = "Open Source game engine for The Elder Scrolls II: Daggerfall";
    categories = [ "Game" ];
  };

  desc = "Open Source game engine for The Elder Scrolls II: Daggerfall in Unity";

in buildFHSUserEnv {
  name = "daggerfall-unity";
  runScript = "${daggerfall-unity-unwrapped}/libexec/DaggerfallUnity.x86_64";
  targetPkgs = pkgs: [
    # Daggerfall
    daggerfall-unity-unwrapped
    # Native deps
    alsa-lib
    libglvnd
    libpulseaudio
    vulkan-loader
    zlib
    # Xorg
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXxf86vm
  ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp -r ${desktopItem}/share/applications $out/share/
    cp -r ${daggerfall-unity-unwrapped}/share/icons/ $out/share/
  '';

  meta = with lib; {
    homepage = "https://www.dfworkshop.net";
    description = "Open Source game engine for The Elder Scrolls II: Daggerfall in Unity";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    architectures = [ "amd64" ];
    maintainers = with maintainers; [ romatthe ];
  };
}
