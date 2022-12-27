{ lib
, stdenv
, fetchFromGitHub
, cmake
, imagemagick
, lsb-release
, ninja
, python3
, file
, glew
, libpng
, libpulseaudio
, libX11
, libXcursor
, libXext
, libXinerama
, libXi
, libXrandr
, SDL2
, requireFile
, baseRom ? requireFile {
    name = "ZELOOTD.z64";
    message = ''
      This nix expression requires that "ZELOOTD.z64" is already part of the store.
      To get this file you can dump your Ocarina of Time cartridge's contents
      and add it to the nix store with "nix-store --add-fixed sha256 <FILE>".
    '';
    sha256 = "94bdeb4ab906db112078a902f4477e9712c4fe803c4efb98c7b97c3f950305ab";
  } }:

# TODO: Support both roms
# TODO: Fetch the gamecontrollerdb file via fetchgit?
# TODO: SubstituInPlace at postPatch or preConfigure?
# TODO: Figure out installPhase (is oot.otr provided installed?)
# TODO: Is `ninja OTRGui` really needed?

stdenv.mkDerivation rec {
  pname = "ship-of-harkinian";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "HarbourMasters";
    repo = "Shipwright";
    rev = version;
    hash = "sha256-sA9sCTSumHBmiTgcL7JewT3tpW6d0OhnjuK0XPONLh4=";
    fetchSubmodules = true;
  };

  # hardeningDisable = [ "format" ];
  hardeningDisable = [ "all" ];

  patches = [
    # ./patches/no-build-info.patch
    # ./patches/no-build-stormlib.patch
    ./no-cmake-curl.patch
  ];

  nativeBuildInputs = [ cmake ninja imagemagick lsb-release python3 ];

  buildInputs = [ glew libpng libpulseaudio libXcursor libXext libXi libXinerama libXrandr SDL2 ];

  cmakeFlags = [
    "-GNinja"
    "-DBUILD_CROWD_CONTROL=off"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "--non-interactive" "${baseRom} --non-interactive"
  '';

  # preConfigure = ''
  #   # ln -s ${baseRom} ./OTRExporter/ZELOOTD.z64
  #   ls -lah .
  #   substituteInPlace CMakeLists.txt \
  #     --replace "--non-interactive" "${baseRom} --non-interactive"
  # '';

  # preBuild = ''
  #   ls -lah .
  #   #cmake --build . --target ExtractAssets
  # '';

  # buildPhase = ''
  #   ls -lah .
  #   ninja ExtractAssets
  #   ninjaBuildPhase
  # '';

  buildPhase = ''
    ninja OTRGui
    ninja ExtractAssets
    ninjaBuildPhase
  '';

  # installPhase = ''
  #   cd soh
  #   cpack -G ZIP
  #   ls -lah .
  # '';

  # buildPhase = ''
  #   runHook preBuild

  #   # file ./OTRExporter/ZELOOTD.z64
  #   # file $(readlink ./OTRExporter/ZELOOTD.z64)
  #   # ls -lah OTRExporter

  #   cmake --build . --target ExtractAssets
  #   cmake --build . --config release

  #   runHook postBuild
  # '';

  postInstall = ''
    install -Dm444 -t $out/oot.otr soh/oot.otr
  '';

  meta = with lib; {
    description = "Open source port of The Legend of Zelda: Ocarina of Time";
    longDescription = ''
      An open source port of The Legend of Zelda: Ocarina of Time based on the oot reverse engineering project.
      Note that you must supply a baserom yourself to extract assets from by adding it to the nix store.
    '';
    homepage = "https://opendungeons.github.io";
    license = with licenses; [ gpl3Plus zlib mit cc-by-sa-30 cc0 ofl cc-by-30 ];
    platforms = platforms.linux;
  };
}
