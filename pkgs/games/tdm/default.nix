{ stdenv, lib, fetchsvn, cmake
, xorg
}:

stdenv.mkDerivation rec {
  pname = "tdm";
  version = "2.11";

  src = fetchsvn {
    url = "https://svn.thedarkmod.com/publicsvn/darkmod_src/tags/${version}";
    rev = "10381";
    sha256 = "rfTcfL3HNWTC/s/XdHQNNCkyHaC2i58rv4cP5I8hXCk=";
  };

  hardeningDisable = [ "format" ];

  cmakeFlags = [
    "-DCOPY_EXE=OFF"
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    xorg.libX11.dev
    xorg.libXext.dev
    xorg.libXxf86vm.dev
  ];

  postBuild = ''
    echo '.'
    ls -lah .
    echo 'build/'
    ls -lah /build/darkmod_src-2.11-r10381/build
    echo '$src'
    ls -lah $src/

    cat ./cmake_install.cmake
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/darkmod/glprogs
    install -Dm755 $PWD/thedarkmod.x64 $out/bin/tdm
    install -Dm644 -t $out/libexec/darkmod/glprogs/* $src/glprogs/*

    runHook postInstall
  '';

  # meta = with lib; {
  #   description = "Emulator of x86-based machines based on PCem.";
  #   homepage = "https://86box.net/";
  #   license = with licenses; [ gpl2Only ] ++ optional unfreeEnableDiscord unfree;
  #   maintainers = [ maintainers.jchw ];
  #   platforms = platforms.linux;
  # };
}
