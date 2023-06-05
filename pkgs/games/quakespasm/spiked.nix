{ lib, stdenv, SDL, SDL2, fetchFromGitHub, gzip, libvorbis, libmad, flac, libopus, opusfile, libogg, libxmp
, Cocoa, CoreAudio, CoreFoundation, IOKit, OpenGL
, cmake, copyDesktopItems, makeDesktopItem, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "quakespasm-spiked";
  version = "20220811";

  src = fetchFromGitHub {
    owner = "Shpoike";
    repo = "Quakespasm";
    rev = "e9822ae";
    sha256 = "sWo4FPFd3iaJqjdhkoKiy5Aj8lJZUspFpTebnYzHFAA=";
  };

  # sourceRoot = "source/Quake";

  # patches = lib.optionals stdenv.isDarwin [
  #   # Makes Darwin Makefile use system libraries instead of ones from app bundle
  #   ./quakespasm-darwin-makefile-improvements.patch
  # ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    gzip libvorbis libmad flac libopus opusfile libogg libxmp SDL2
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa CoreAudio IOKit OpenGL CoreFoundation
  ];

  buildFlags = [
    "DO_USERDIRS=1"
    # Makefile defaults, set here to enforce consistency on Darwin build
    "USE_CODEC_WAVE=1"
    "USE_CODEC_MP3=1"
    "USE_CODEC_VORBIS=1"
    "USE_CODEC_FLAC=1"
    "USE_CODEC_OPUS=1"
    "USE_CODEC_MIKMOD=0"
    "USE_CODEC_UMX=0"
    "USE_CODEC_XMP=1"
    "MP3LIB=mad"
    "VORBISLIB=vorbis"
    "SDL_CONFIG=sdl2-config"
    "USE_SDL2=1"
  ];

  # makefile = if (stdenv.isDarwin) then "Makefile.darwin" else "Makefile";

  preInstall = ''
    # mkdir -p "$out/bin"
    # substituteInPlace Makefile --replace "/usr/local/games" "$out/bin"
    # substituteInPlace Makefile.darwin --replace "/usr/local/games" "$out/bin"
    ls -lah /build/
    ls -lah .
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -T quakespasm $out/bin/quakespasm-spiked

    runHook postInstall
  '';

  enableParallelBuilding = true;

  desktopItems = [
    (makeDesktopItem {
      name = "quakespasm-spiked";
      exec = "quakespasm-spiked";
      desktopName = "Quakespasm Spiked";
      categories = [ "Game" ];
    })
  ];

  meta = with lib; {
    description = "An engine for iD software's Quake based on Quakespasm";
    homepage = "https://triptohell.info/moodles/qss/";
    longDescription = ''
      QuakeSpasm is a modern, cross-platform Quake 1 engine based on FitzQuake.
      It includes support for 64 bit CPUs and custom music playback, a new sound driver,
      some graphical niceities, and numerous bug-fixes and other improvements.
      Quakespasm utilizes either the SDL or SDL2 frameworks, so choose which one
      works best for you. SDL is probably less buggy, but SDL2 has nicer features
      and smoother mouse input - though no CD support.
    '';

    platforms = platforms.unix;
    maintainers = with maintainers; [ mikroskeem ];
    mainProgram = "quake";
  };
}
