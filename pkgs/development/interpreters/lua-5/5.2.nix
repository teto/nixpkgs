# look at python/wrapper.nix
# look at setup hooks too
{ stdenv, fetchurl, readline, compat ? false
, hostPlatform, makeWrapper
, lua-setup-hook, callPackage
, self
, packageOverrides ? (self: super: {})
# , filter # in fact in with stdenv.lib;
# , getLuaPath
# , getLuaCPath
}:

let
  dsoPatch = fetchurl {
    url = "https://projects.archlinux.org/svntogit/packages.git/plain/trunk/liblua.so.patch?h=packages/lua52";
    sha256 = "1by1dy4ql61f5c6njq9ibf9kaqm3y633g2q8j54iyjr4cxvqwqz9";
    name = "lua-arch.patch";
  };
buildInputs = [];
  # buildInputs = filter (p: p != null) [
  #   # zlib bzip2 expat lzma libffi gdbm sqlite
  #   readline
  # ]
    # ++ optionals x11Support [ tcl tk libX11 xproto ]
    # ++ optionals stdenv.isDarwin [ CF configd ]
    # ;


in
stdenv.mkDerivation rec {
  name = "lua-${version}";
  majorVersion = "5.2";
  luaversion = "${majorVersion}";
  # TODO use majorVersion
  # libPrefix = getLuaPath "${majorVersion}";
  # libCPrefix = getLuaCPath "${majorVersion}";

  # inherit buildInputs;
  version = "${majorVersion}.3";

  src = fetchurl {
    url = "http://www.lua.org/ftp/${name}.tar.gz";
    sha256 = "0b8034v1s82n4dg5rzcn12067ha3nxaylp2vdp8gg08kjsbzphhk";
  };

  nativeBuildInputs = [ readline ];

  patches = if stdenv.isDarwin then [ ./5.2.darwin.patch ] else [ dsoPatch ];

  # sitePackages best if it returns a string/file

  # todo make it a list ? function generator
  libFolder = "lib/lua/${majorVersion}";

  # setup hook runs on propagatedBuildInputs
  # hook useless won't find any good libraries
  setupHook = lua-setup-hook ;
  # setupHook = ./setup-hook.sh;

  # have a look at cython3.6
  # buildEnv = callPackage ./wrapper.nix {
  #   # lua = self;
  # };


  passthru = let
    luaPackages = callPackage ../../../top-level/lua-packages.nix {lua=self; overrides=packageOverrides;};
  in rec {
    # executable = "${libPrefix}m";
    buildEnv = callPackage ./wrapper.nix { lua = self;
    # inherit (luaPackages) requiredLuaModules;
    };
    withPackages = import ./with-packages.nix { inherit buildEnv luaPackages;};
    pkgs = luaPackages;
    interpreter = "${self}/bin/lua";
  };


  enableParallelBuilding = true;

  configurePhase =
    if stdenv.isDarwin
    then ''
    makeFlagsArray=( INSTALL_TOP=$out INSTALL_MAN=$out/share/man/man1 PLAT=macosx CFLAGS="-DLUA_USE_LINUX -fno-common -O2 -fPIC${if compat then " -DLUA_COMPAT_ALL" else ""}" LDFLAGS="-fPIC" V=${majorVersion} R=${majorVersion} )
    installFlagsArray=( TO_BIN="lua luac" TO_LIB="liblua.${version}.dylib" INSTALL_DATA='cp -d' )
  '' else ''
    makeFlagsArray=( INSTALL_TOP=$out INSTALL_MAN=$out/share/man/man1 PLAT=linux CFLAGS="-DLUA_USE_LINUX -O2 -fPIC${if compat then " -DLUA_COMPAT_ALL" else ""}" LDFLAGS="-fPIC" V=${majorVersion} R=${version} )
    installFlagsArray=( TO_BIN="lua luac" TO_LIB="liblua.a liblua.so liblua.so.${majorVersion} liblua.so.${version}" INSTALL_DATA='cp -d' )
  '';

    # postBuild = ''
    #   . "${makeWrapper}/nix-support/setup-hook"

    #   if [ -L "$out/bin" ]; then
    #       unlink "$out/bin"
    #   fi
    #   mkdir -p "$out/bin"

    #   for path in ${stdenv.lib.concatStringsSep " " paths}; do
    #     if [ -d "$path/bin" ]; then
    #       cd "$path/bin"
    #       for prg in *; do
    #         if [ -f "$prg" ]; then
    #           rm -f "$out/bin/$prg"
    #           if [ -x "$prg" ]; then
    #             makeWrapper "$path/bin/$prg" "$out/bin/$prg" --set PYTHONHOME "$out" --set PYTHONNOUSERSITE "true"
    #           fi
    #         fi
    #       done
    #     fi
    #   done
    # '' + postBuild;

  postInstall = ''
    mkdir -p "$out/share/doc/lua" "$out/lib/pkgconfig"
    mv "doc/"*.{gif,png,css,html} "$out/share/doc/lua/"
    rmdir $out/{share,lib}/lua/${majorVersion} $out/{share,lib}/lua
    mkdir -p "$out/lib/pkgconfig"
    cat >"$out/lib/pkgconfig/lua.pc" <<EOF
    prefix=$out
    libdir=$out/lib
    includedir=$out/include
    INSTALL_BIN=$out/bin
    INSTALL_INC=$out/include
    INSTALL_LIB=$out/lib
    INSTALL_MAN=$out/man/man1

    Name: Lua
    Description: An Extensible Extension Language
    Version: ${version}
    Requires:
    Libs: -L$out/lib -llua -lm
    Cflags: -I$out/include
    EOF
  '';

  crossAttrs = let
    inherit (hostPlatform) isDarwin isMingw;
  in {
    configurePhase = ''
      makeFlagsArray=(
        INSTALL_TOP=$out
        INSTALL_MAN=$out/share/man/man1
        V=${majorVersion}
        R=${version}
        ${if isMingw then "mingw" else stdenv.lib.optionalString isDarwin ''
        ''}
      )
    '' + stdenv.lib.optionalString isMingw ''
      installFlagsArray=(
        TO_BIN="lua.exe luac.exe"
        TO_LIB="liblua.a lua52.dll"
        INSTALL_DATA="cp -d"
      )
    '';
  } // stdenv.lib.optionalAttrs isDarwin {
    postPatch = ''
      sed -i -e 's/-Wl,-soname[^ ]* *//' src/Makefile
    '';
  };

  meta = {
    homepage = http://www.lua.org;
    description = "Powerful, fast, lightweight, embeddable scripting language";
    longDescription = ''
      Lua combines simple procedural syntax with powerful data
      description constructs based on associative arrays and extensible
      semantics. Lua is dynamically typed, runs by interpreting bytecode
      for a register-based virtual machine, and has automatic memory
      management with incremental garbage collection, making it ideal
      for configuration, scripting, and rapid prototyping.
    '';
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.unix;
  };
}
