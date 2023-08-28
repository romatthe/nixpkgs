{ lib
, stdenv
, fetchFromGitHub
, allegro5
, boron
, libpng
, libpulseaudio
, libvorbis
, pulseaudio
}:
let
  faun = stdenv.mkDerivation rec {
    pname = "faun";
    version = "0.1.3";

    src = fetchFromGitHub {
      owner = "WickedSmoke";
      repo = "faun";
      rev = "v${version}";
      hash = "sha256-OkY7+o4gaPS/QUvhaemhjiyMnqD7ZVpL7+fiD8cM7KE=";
    };

    buildinputs = [ libpulseaudio.dev libvorbis ];

    # configureFlags = [ "--prefix $out" ];

    # preConfigure = ''
    #   patchShebangs --build configure
    # '';

    configurePhase = ''
      # Configure scripts uses --prefix <dir> instead of --prefix=<dir>
      patchShebangs --build configure
      ./configure --prefix $out
    '';
  };
in stdenv.mkDerivation rec {
  pname = "xu4";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "xu4-engine";
    repo = "u4";
    rev = "v${version}";
    hash = "sha256-3jyUSVfmjuKsHQKluFnQ8Gtg7aAI/WBjmY109BdNdyY=";
    fetchSubmodules = true;
  };

  buildInputs = [
    allegro5
    boron
    # faun
    libpng
    libvorbis
  ];

  postPatch = ''
    rm -Rf src/glv
  '';

  configurePhase = ''
    patchShebangs --build configure
    ./configure --prefix $out
  '';

  meta = with lib; {
    description = "A multi-player version of the classical game of Tetris, for the X Window system";
    homepage = "https://web.archive.org/web/20120315061213/http://www.iagora.com/~espel/xtris/xtris.html";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
