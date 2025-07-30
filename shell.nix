{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    #WASM
	emscripten

    glfw         # If raylib is being built with GLFW support
    pkg-config   # For resolving library paths

    # Required system libraries
    libGL
	mesa
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    xorg.libXxf86vm
    xorg.libXcursor

    # Standard Linux libs (usually provided by glibc)
    glibc
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
      pkgs.libGL
      pkgs.glibc
      pkgs.mesa
      pkgs.xorg.libX11
      pkgs.xorg.libXrandr
      pkgs.xorg.libXinerama
      pkgs.xorg.libXi
      pkgs.xorg.libXxf86vm
      pkgs.xorg.libXcursor
    ]}:$LD_LIBRARY_PATH

    export EMSDK="${pkgs.emscripten}"

    export EM_CACHE=$PWD/.emcache
    mkdir -p $EM_CACHE
	cp -r $EMSDK/share/emscripten/cache/* $EM_CACHE
	chmod -R u+rwX $EM_CACHE
  '';
}

