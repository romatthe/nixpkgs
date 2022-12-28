{ stdenv
, lib
, buildFHSUserEnv
, fetchzip
, autoPatchelfHook
, alsa-lib
, libglvnd
, libpulseaudio
, xorg
, zlib
}:

let
  daggerfall-unity-unwrapped = stdenv.mkDerivation rec {
    pname = "daggerfall-unity";
    version = "0.14.5";

    src = fetchzip {
      url = "https://github.com/Interkarma/daggerfall-unity/releases/download/v0.14.5-beta/dfu_linux_64bit-v${version}-beta.zip";
      sha256 = "8OXIzkyVZgSbDtcB+BreFSHNJqTKP2kNRWgibWwwZtc=";
      stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;
    dontAutoPatchElf = false;

    nativeBuildInputs = [
      # autoPatchelfHook
    ];

    buildInputs = [
      zlib
    ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p "$out/bin"
      cp -R source/* "$out/bin"
    '';

    meta = with lib; {
      homepage = "https://www.dfworkshop.net";
      description = "Open Source engine for The Elder Scrolls II: Daggerfall in Unity";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      architectures = [ "amd64" ];
      maintainers = with maintainers; [ romatthe ];
    };
  };
in buildFHSUserEnv {
  name = "daggerfall-unity";
  runScript = "DaggerfallUnity.x86_64";
  targetPkgs = pkgs: [
    # Daggerfall
    daggerfall-unity-unwrapped
    # Native deps
    alsa-lib
    libglvnd
    libpulseaudio
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

  meta = with lib; {
    homepage = "https://www.dfworkshop.net";
    description = "Open Source game engine for The Elder Scrolls II: Daggerfall in Unity";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    architectures = [ "amd64" ];
    maintainers = with maintainers; [ romatthe ];
  };
}
