{ lib
, stdenv
, fetchzip
, makeWrapper
, wrapGAppsHook
, copyDesktopItems
, makeDesktopItem
, ant
, imagemagick
# Pinned to the latest LTS release, update jdk_lts when upgrading.
, jdk17
, jre_minimal
}:
let
  desktopItem = makeDesktopItem {
    name = "dbgl";
    exec = "dbgl";
    icon = "dbgl";
    desktopName = "DOSBox Game Launcher";
    comment = "Cross-platform game-centric frontend for DOSBox";
    categories = [ "Game" "Emulator" ];
    keywords = [ "emulator" "emulation" "front-end" "frontend" "dosbox" ];
  };
  jdk_lts = jdk17; # Pinned!
  jre_mod = jre_minimal.override {
    jdk = jdk_lts;
    modules = [
      "java.base"
      "java.datatransfer"
      "java.desktop"
      "java.logging"
      "java.naming"
      "java.prefs"
      "java.scripting"
      "java.security.sasl"
      "java.sql"
      "java.transaction.xa"
      "java.xml"
      "jdk.crypto.ec"
      "jdk.localedata"
      "jdk.unsupported"
    ];
  };
in
stdenv.mkDerivation rec {
  name = "dbgl";
  version = "0.97";
  src = fetchzip {
    url = "https://dbgl.org/download/src${builtins.replaceStrings ["."] [""] version}}.zip";
    hash = "sha256-qxq/+8b4H/PMt+4+tYtt3N8CSpRgfZHOAXTxIavcNMU=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    ant
    copyDesktopItems
    imagemagick
    jdk_lts
    makeWrapper
    wrapGAppsHook
  ];

  dontWrapGApps = true;

  buildPhase = "ant distlinux";

  installPhase = ''
    runHook preInstall

    mkdir build/
    tar -xf dist/dbgl*.tar.gz -C build/

    mkdir -p $out/share/dbgl $out/share/dbgl/db $out/share/dbgl/lib \
      $out/share/dbgl/templates $out/share/dbgl/xsl

    install -Dm644 build/db/*        $out/share/dbgl/db
    install -Dm644 build/lib/*       $out/share/dbgl/lib
    install -Dm644 build/templates/* $out/share/dbgl/templates
    install -Dm644 build/xsl/*       $out/share/dbgl/xsl
    install -Dm644 build/dbgl.jar    $out/share/dbgl/

    for size in 16 24 32 48 64 128 256 ; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" build/dbgl.png $out/share/icons/hicolor/"$size"x"$size"/apps/dbgl.png
    done;

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${jre_mod}/bin/java $out/bin/dbgl \
      --add-flags "-jar $out/share/dbgl/dbgl.jar" \
      --add-flags "-Djava.library.path=$out/share/dbgl/lib" \
      --add-flags "-Ddbgl.data.userhome=true" \
      --prefix PATH : ${lib.makeBinPath [ jre_mod ]} \
      --set JAVA_HOME ${lib.getBin jre_mod} \
      --set SWT_GTK 0 \
      --chdir $out/share/dbgl \
      "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [ desktopItem ];
}
