# Wrapper around wrapLuaProgramsIn, below. The $luaPath
# variable is passed in from the buildLuaPackage function.
wrapLuaPrograms() {
    echo "wrap.sh : wrapLuaPrograms"
    wrapLuaProgramsIn "$out/bin" "$out $luaPath"
}

# Builds environment variables like LUA_PATH and PATH walking through closure
# of dependencies.
buildLuaPath() {
    local luaPath="$1"
    local path

    echo "buildLuaPath"
    # Create an empty table of python paths (see doc on _addToLuaPath
    # for how this is used). Build up the program_PATH and program_LUA_PATH
    # variables.
    declare -A luaPathsSeen=()
    program_LUA_PATH=
    program_LUA_CPATH=
    program_PATH=
    luaPathsSeen["@lua@"]=1
    #
    addToLuaSearchPath program_PATH @lua@/bin
    for path in $luaPath; do
        _addToLuaPath "$path"
    done
}


# with an executable shell script which will set some environment variables
# and then call into the original binary (which has been given a .wrapped
# suffix).
# luaPath is a list of directories
wrapLuaProgramsIn() {
    local dir="$1"
    local luaPath="$2"
    local f

    buildLuaPath "$luaPath"

    echo "wrapLuaProgram call with dir $dir"
    # Find all regular files in the output directory that are executable.
    if [ -d "$dir" ]; then
        echo "$dir is a folder"
        find "$dir" -type f -perm -0100 -print0 | while read -d "" f; do
            # Rewrite "#! .../env python" to "#! /nix/store/.../python".
            # Strip suffix, like "3" or "2.7m" -- we don't have any choice on which
            # Lua to use besides one with this hook anyway.
            if head -n1 "$f" | grep -q '#!.*/env.*\(lua\)'; then
                echo "we found a call to lua, replacing"
                sed -i "$f" -e "1 s^.*/env[ ]*\(lua\)[^ ]*^#! @executable@^"
            fi

            # catch /python and /.python-wrapped
            # if head -n1 "$f" | grep -q '/\.\?\(lua\|pypy\)'; then
                # dont wrap EGG-INFO scripts since they are called from python
                # if echo "$f" | grep -qv EGG-INFO/scripts; then
                    # wrapProgram creates the executable shell script described
                    # above. The script will set LUA_PATH and PATH variables.!
                    # (see pkgs/build-support/setup-hooks/make-wrapper.sh)
                    local -a wrap_args=("$f"
                                    --prefix PATH ':' "$program_PATH"
                                    --prefix LUA_PATH ';' "$program_LUA_PATH"
                                    --prefix LUA_CPATH ';' "$program_LUA_CPATH"
                                    )

                    # Add any additional arguments provided by makeWrapperArgs
                    # argument to buildLuaPackage.
                    # makeWrapperArgs
                    local -a user_args="($makeWrapperArgs)"
                    local -a wrapProgramArgs=("${wrap_args[@]}" "${user_args[@]}")

                    # see setup-hooks/make-wrapper.sh
                    # makeWrapperArgs
                    wrapProgram "${wrapProgramArgs[@]}"

                # fi
            # fi
        done
    fi
}

addToLuaSearchPathWithCustomDelimiter() {
    local delimiter="$1"
    local varName="$2"
    local dir="$3"
    local suffix="$4"
    echo "=> checking dir $3"
    if  [ -d "$dir" ]; then
        export "${varName}=${!varName:+${!varName}${delimiter}}${dir}${suffix}"
        echo "VALID entry; exporting $3"
        echo "$varName=${!varName}"
    else
        echo "$3 not a directory; ignoring"
    fi
}

addToLuaSearchPath() {
    addToLuaSearchPathWithCustomDelimiter ";" "$@"
}


# Adds the lib and bin directories to the LUA_PATH and PATH variables,
# respectively. Recurses on any paths declared in
# `propagated-native-build-inputs`, while avoiding duplicating paths by
# flagging the directories it has visited in `luaPathsSeen`.
_addToLuaPath() {
    local dir="$1"
    # Stop if we've already visited here.
    echo "call to _addToLuaPath '$dir'"
    if [ -n "${luaPathsSeen[$dir]}" ]; then
        echo "path $dir already visited"
        return;
    fi
    luaPathsSeen[$dir]=1
    addToLuaSearchPath program_LUA_PATH "$dir/lib/lua/@luaversion@" "/?.lua"
    addToLuaSearchPath program_LUA_PATH "$dir/share/lua/@luaversion@" "/?.lua"
    addToLuaSearchPath program_LUA_CPATH "$dir/lib/lua/@luaversion@" "/?.so"
    addToLuaSearchPath program_LUA_CPATH "$dir/share/lua/@luaversion@" "/?.so"

    # Inspect the propagated inputs (if they exist) and recur on them.
    local prop="$dir/nix-support/propagated-native-build-inputs"
    if [ -e "$prop" ]; then
        local new_path
        for new_path in $(cat $prop); do
            _addToLuaPath "$new_path"
        done
    fi
	echo "we program_LUA_PATH=$program_LUA_PATH"
	echo "we get program_LUA_CPATH=$program_LUA_CPATH"
}

