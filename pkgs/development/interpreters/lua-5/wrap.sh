# Wrapper around wrapLuaProgramsIn, below. The $luaPath
# variable is passed in from the buildLuaPackage function.
wrapLuaPrograms() {
    wrapLuaProgramsIn "$out/bin" "$out $luaPath"
}

# Builds environment variables like LUA_PATH and PATH walking through closure
# of dependencies.
buildLuaPath() {
    local luaPath="$1"
    local path

    # Create an empty table of python paths (see doc on _addToLuaPath
    # for how this is used). Build up the program_PATH and program_LUA_PATH
    # variables.
    declare -A luaPathsSeen=()
    program_LUA_PATH=
    program_LUA_CPATH=
    program_PATH=
    luaPathsSeen["@lua@"]=1
    addToSearchPath program_PATH @lua@/bin
    for path in $luaPath; do
        _addToLuaPath $path
    done
}

# Patches a Lua script so that it has correct libraries path and executable
# name.
patchLuaScript() {
    local f="$1"

    # The magicalSedExpression will invoke a "$(basename "$f")", so
    # if you change $f to something else, be sure to also change it
    # in pkgs/top-level/python-packages.nix!
    # It also uses $program_LUA_PATH.
    echo "patching lua script "
    # sed -i "$f" -re '@magicalSedExpression@'
}

#  replacing them
# with an executable shell script which will set some environment variables
# and then call into the original binary (which has been given a .wrapped
# suffix).
# luaPath is a list of directroeis
wrapLuaProgramsIn() {
    local dir="$1"
    local luaPath="$2"
    local f

    buildLuaPath "$luaPath"

    # Find all regular files in the output directory that are executable.
    if [ -d "$dir" ]; then
        find "$dir" -type f -perm -0100 -print0 | while read -d "" f; do
            # Rewrite "#! .../env python" to "#! /nix/store/.../python".
            # Strip suffix, like "3" or "2.7m" -- we don't have any choice on which
            # Lua to use besides one with this hook anyway.
            if head -n1 "$f" | grep -q '#!.*/env.*\(lua\)'; then
                sed -i "$f" -e "1 s^.*/env[ ]*\(lua\)[^ ]*^#! @executable@^"
            fi

            # catch /python and /.python-wrapped
            # if head -n1 "$f" | grep -q '/\.\?\(lua\|pypy\)'; then
                # dont wrap EGG-INFO scripts since they are called from python
                # if echo "$f" | grep -qv EGG-INFO/scripts; then
                    echo "wrapping \`$f'..."
                    patchLuaScript "$f"
                    echo "wrapping with LUA_PATH=$program_LUA_PATH"
                    # wrapProgram creates the executable shell script described
                    # above. The script will set LUA_PATH and PATH variables.!
                    # (see pkgs/build-support/setup-hooks/make-wrapper.sh)
                    local -a wrap_args=("$f"
                                    --prefix PATH ':' "$program_PATH"
                                    --set "LUA_PATH" "$program_LUA_PATH"
                                    --set "LUA_CPATH" "$program_LUA_CPATH"
                                    )

                    # Add any additional arguments provided by makeWrapperArgs
                    # argument to buildLuaPackage.
                    local -a user_args="($makeWrapperArgs)"
                    local -a wrapProgramArgs=("${wrap_args[@]}" "${user_args[@]}")
                    wrapProgram "${wrapProgramArgs[@]}"
                # fi
            # fi
        done
        TOTO=1
    fi
}

# Adds the lib and bin directories to the LUA_PATH and PATH variables,
# respectively. Recurses on any paths declared in
# `propagated-native-build-inputs`, while avoiding duplicating paths by
# flagging the directories it has visited in `luaPathsSeen`.
_addToLuaPath() {
    local dir="$1"
    # Stop if we've already visited here.
    echo "call to _addToLuaPath '$1'"
    if [ -n "${luaPathsSeen[$dir]}" ]; then return; fi
    luaPathsSeen[$dir]=1
    # addToSearchPath is defined in stdenv/generic/setup.sh. It will have
    # the effect of calling `export program_X=$dir/...:$program_X`.
    addToSearchPath program_LUA_PATH "$dir/@libFolder@"
    addToSearchPath program_LUA_CPATH "$dir/toto"
    addToSearchPath program_PATH "$dir/bin"

    # Inspect the propagated inputs (if they exist) and recur on them.
    local prop="$dir/nix-support/propagated-native-build-inputs"
    if [ -e $prop ]; then
        local new_path
        for new_path in $(cat $prop); do
            _addToLuaPath $new_path
        done
    fi
}

# createBuildInputsPth() {
#     local category="$1"
#     local inputs="$2"
#     if [ foo"$inputs" != foo ]; then
#         for x in $inputs; do
#             if $(echo -n $x |grep -q python-recursive-pth-loader); then
#                 continue
#             fi
#             if test -d "$x"/lib/@libPrefix@/site-packages; then
#                 echo $x/lib/@libPrefix@/site-packages \
#                     >> "$out"/lib/@libPrefix@/site-packages/${name}-nix-python-$category.pth
#             fi
#         done
#     fi
# }
