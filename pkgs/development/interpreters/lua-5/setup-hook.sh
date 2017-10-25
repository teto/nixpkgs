# TODO do the same for LUA_CPATH other file or ?
# addLuaPath() {
#     # where does it come from addToSearchPathWithCustomDelimiter ?
#     # defined in stdenv/generic/setup.sh|172
#     # delimiter/varname/dir
#     # todo fix it should not be a dir but rahter ?.lua etc..
#     # TODO it should happen only for some folder
#     # can I get the version ?
#     # see getLuaPath
#     # substituion @var@ onl happens for environement variables
#     folder="$1/@libFolder@/?.lua"
#     addToSearchPathWithCustomDelimiter ';' LUA_PATH $folder
#     # addToSearchPathWithCustomDelimiter ';' LUA_CPATH "$1/lib/lua/5.1/?.lua"
#     echo "addLuaPath called $folder"
# }

addToLuaSearchPathWithCustomDelimiter() {
    local delimiter="$1"
    local varName="$2"
    local dir="$3"
    local suffix="$4"
    echo "===> checking dir $3"
    if  [ -d "$dir" ]; then
        export "${varName}=${!varName:+${!varName}${delimiter}}${dir}${suffix}"
        echo "VALID entry; exporting $3"
    else
        echo "$3 not a directory; ignoring"
    fi
}

# PATH_DELIMITER=':'

addToLuaSearchPath() {
    addToLuaSearchPathWithCustomDelimiter ";" "$@"
}

startLuaEnvHook() {
echo "STARTING LUA ENV HOOK"
addToLuaPath "$1"
echo "FINISHED LUA ENV HOOK"

}

# Adds the lib and bin directories to the LUA_PATH and PATH variables,
# respectively. Recurses on any paths declared in
# `propagated-native-build-inputs`, while avoiding duplicating paths by
# flagging the directories it has visited in `luaPathsSeen`.
addToLuaPath() {
    local dir="$1"
    # Stop if we've already visited here.
    echo "call to addToLuaPath '$dir'"
    # if [ -n "${luaPathsSeen["$dir"]}" ]; then
    #     echo "path $dir already visited"
    #     return;
    # fi
    # luaPathsSeen[$dir]=1
    # addToLuaSearchPath is defined in stdenv/generic/setup.sh. It will have
    # the effect of calling `export program_X=$dir/...:$program_X`.
    # echo "Add to search path $dir/@libFolder@"
  # getPath       = aib : type : "${lib}/lib/lua/${lua.luaversion}/?.${type};${lib}/share/lua/${lua.luaversion}/?.${type}";
  # TODO rename to majorVersion
    addToLuaSearchPath LUA_PATH "$dir/lib/lua/@luaversion@" "/?.lua"
    addToLuaSearchPath LUA_PATH "$dir/share/lua/@luaversion@" "/?.lua"
    addToLuaSearchPath LUA_CPATH "$dir/lib/lua/@luaversion@" "/?.so"
    addToLuaSearchPath LUA_CPATH "$dir/share/lua/@luaversion@" "/?.so"
    # addToLuaSearchPath program_PATH "$dir/bin"

    # Inspect the propagated inputs (if they exist) and recur on them.
    # local prop="$dir/nix-support/propagated-native-build-inputs"
    # if [ -e "$prop" ]; then
    #     local new_path
    #     for new_path in $(cat "$prop"); do
    #         addToLuaPath "$new_path"
    #     done
    # fi
    echo "LUA_PATH=$LUA_PATH"
    echo "LUA_CPATH=$LUA_CPATH"
}


envHooks+=(startLuaEnvHook)

