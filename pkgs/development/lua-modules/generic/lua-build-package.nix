# { lua, stdenv, wrapLua
# # Execute before shell hook
# , preShellHook ? ""
# # Execute after shell hook
# , postShellHook ? ""
# }:

# { buildInputs ? [], disabled ? false, ... } @ attrs:

# if disabled then
#   throw "${attrs.name} not supported by interpreter lua-${lua.luaversion}"
# else
#   lua.stdenv.mkDerivation ({

#       preBuild = ''
#         makeFlagsArray=(
#           PREFIX=$out
#           LUA_LIBDIR="$out/lib/lua/${lua.luaversion}"
#           LUA_INC="-I${lua}/include");
#       '';

#     }
#     //
#     attrs
#     //
#     {
#       name = "lua${lua.luaversion}-" + attrs.name;
#       buildInputs = buildInputs ++ [ wrapLua ];

#       libFolder = "$out/lib/lua/${lua.luaversion}";

#       # bahs function defined in wrap.sh
#       postFixup = stdenv.lib.optionalString (true) ''
#       wrapLuaPrograms
#       '';
#       # TODO add it if it exists
#       # + attrs.postFixup;
#   # buildInputs = buildInputs ++ [ bootstrapped-pip ];

#   # configurePhase = attrs.configurePhase or ''
#   #   runHook preConfigure
#   #   runHook postConfigure
#   # '';
#   shellHook = attrs.shellHook or ''
#     ${preShellHook}
#       # tmp_path=$(mktemp -d)
#       export PATH="$tmp_path/bin:$PATH"
#       export MATTATR="HELLO WORLD"
#       # mkdir -p $tmp_path/
#     ${postShellHook}
#   '';
#   installPhase = attrs.installPhase or ''
#     runHook preInstall

#     # mkdir -p "$out/toto"
#     export MATTATOR="$out/MATT:$PYTHONPATH"

#     runHook postInstall
#   '';

#     # TODO maybe we wwant to create the lib package automatically
#     # TODO
#     # export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"

#   # installPhase = attrs.installPhase or ''
#   #   runHook preInstall

#   #   mkdir -p "$out/toto"
#   #   export LUA_PATH="$out/toto:$LUA_PATH"


#   #   runHook postInstall
#   #   '';

#       # but this is not exported ??
#       # LUA_PATH = stdenv.lib.concatStringsSep ";" (map getLuaPath "$out/lib/lua/${lua.luaversion}");
#       # LUA_CPATH = stdenv.lib.concatStringsSep ";" (map getLuaCPath lualibs);

#     }
#   )
