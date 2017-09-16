# TODO do the same for LUA_CPATH other file or ?
addLuaPath() {
    # where does it come from addToSearchPathWithCustomDelimiter ?
    # defined in stdenv/generic/setup.sh|172
    # delimiter/varname/dir
    # todo fix it should not be a dir but rahter ?.lua etc..
    # TODO it should happen only for some folder
    # can I get the version ?
    # see getLuaPath
    # substituion @var@ onl happens for environement variables
    folder="$1/@libFolder@/?.lua"
    addToSearchPathWithCustomDelimiter ';' LUA_PATH $folder
    # addToSearchPathWithCustomDelimiter ';' LUA_CPATH "$1/lib/lua/5.1/?.lua"
    echo "addLuaPath called $folder"
}

# toLuaPath() {
#     local paths="$1"
#     local result=
#     for i in $paths; do
#         p="$i/@sitePackages@"
#         result="${result}${result:+:}$p"
#     done
#     echo $result
# }

envHooks+=(addLuaPath)

# Determinism: The interpreter is patched to write null timestamps when compiling python files.
# This way python doesn't try to update them when we freeze timestamps in nix store.
export DETERMINISTIC_BUILD=1;
# Determinism: We fix the hashes of str, bytes and datetime objects.
# export PYTHONHASHSEED=0;
