addToLuaSearchPathWithCustomDelimiter() {
    local delimiter="$1"
    local varName="$2"
    local dir="$3"
    local suffix="$4"
    echo "=> checking dir $3"
    if  [ -d "$dir" ]; then
        set -x
        export "${varName}=${!varName:+${!varName}${delimiter}}${dir}${suffix}"
        set +x
        echo "VALID entry; appending to $varName $3"
    else
        echo "$3 not a directory; ignoring"
    fi
}

addToLuaSearchPath() {
    addToLuaSearchPathWithCustomDelimiter ";" "$@"
}

startLuaEnvHook() {
addToLuaPath "$1"
}

# Adds the lib and bin directories to the LUA_PATH and PATH variables,
# respectively. Recurses on any paths declared in
# `propagated-native-build-inputs`, while avoiding duplicating paths by
# flagging the directories it has visited in `luaPathsSeen`.
addToLuaPath() {
    local dir="$1"
    echo "call to addToLuaPath '$dir'"

    addToLuaSearchPath LUA_PATH "$dir/lib/lua/@luaversion@" "/?.lua"
    addToLuaSearchPath LUA_PATH "$dir/share/lua/@luaversion@" "/?.lua"
    addToLuaSearchPath LUA_PATH "$dir/share/lua/@luaversion@" "/?/init.lua"
    addToLuaSearchPath LUA_PATH "$dir/lib/lua/@luaversion@" "/?/init.lua"
    addToLuaSearchPath LUA_CPATH "$dir/lib/lua/@luaversion@" "/?.so"
    addToLuaSearchPath LUA_CPATH "$dir/share/lua/@luaversion@" "/?.so"

    echo "LUA_PATH=$LUA_PATH"
    echo "LUA_CPATH=$LUA_CPATH"
}

addEnvHooks "$hostOffset" startLuaEnvHook

