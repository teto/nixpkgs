{ lua,
stdenv,
buildLuaPackage,
fetchurl
}:
buildLuaPackage rec {
    name = "cjson-${version}";
    version = "2.1.0";
    src = fetchurl {
      url = "http://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz";
      sha256 = "0y67yqlsivbhshg8ma535llz90r4zag9xqza5jx0q7lkap6nkg2i";
    };
    # nativeBuildInputs = [ lua ];
    # propagatedBuildInputs = [ lua ];
    # to overwrite PREFIX and fix all paths
    # TODO pass it as PREFIX rather. but out doesn't seem like the good way
    preBuild = ''
      sed -i "s|/usr/local|$out|" Makefile
    '';
    makeFlags = [ "VERBOSE=1" "LUA_VERSION=${lua.luaversion}" ];
    # why would you do that ?
    postInstall = ''
      rm -rf $out/share/lua/${lua.luaversion}/cjson/tests
    '';

    # LOULOU="eaezea";

    # postFixup = ''
    #   echo postfixup called
    #   export TOTO="toto"
    # '';

    shellHook=''
      echo "hello world";
      '';

    installTargets = "install install-extra";
    # installPhase = ''
    #   mkdir -p $out/lib/lua/${lua.luaversion}
    #   install -p re.lua $out/lib/lua/${lua.luaversion}
    # '';
    meta = {
      description = "Lua C extension module for JSON support";
      license = stdenv.lib.licenses.mit;
    };
  }

