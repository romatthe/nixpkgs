{ stdenv, lib, fetchsvn, cmake, pkg-config
, xorg, zlib
}:
let
  version = "2.11";
  src = fetchsvn {
    url = "https://svn.thedarkmod.com/publicsvn/darkmod_src/tags/${version}";
    rev = "10381";
    sha256 = "rfTcfL3HNWTC/s/XdHQNNCkyHaC2i58rv4cP5I8hXCk=";
  };
  tdm_installer = stdenv.mkDerivation {
    inherit version src;

    pname = "tdm_installer";
    # src = "${src}/tdm_installer";

    nativeBuildInputs = [ cmake pkg-config ];
    buildInputs = [ pkg-config xorg.libX11.dev xorg.libXext.dev zlib zlib.dev ];

    configurePhase = ''
      runHook preConfigure

      mkdir build && cd build;
      cmake -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=Release ../tdm_installer

      runHook postConfigure
    '';

    preInstall = ''
      ls -lah .
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 $PWD/tdm_installer.linux64 $out/bin/tdm_installer

      runHook postInstall
    '';
  };
in
  stdenv.mkDerivation rec {
    inherit src version;
    pname = "tdm";

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

      echo 'lol'

      cat ./cmake_install.cmake
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/darkmod
      install -Dm755 $PWD/thedarkmod.x64 $out/bin/tdm
      install -Dm755 ${tdm_installer}/bin/tdm_installer $out/bin/tdm_installer
      # install -Dm644 $src/glprogs/* $out/libexec/darkmod/glprogs/
      cp -r $src/glprogs $out/libexec/darkmod

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
