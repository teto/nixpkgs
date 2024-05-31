#!/bin/bash
nix_print() {
  if [ ${NIX_DEBUG:-0} -ge $1 ]; then
    echo "$2"
  fi
}

nix_debug() {
  nix_print 3 "$1"
}

addToLuaSearchPathWithCustomDelimiter() {
  local varName="$1"
  local absPattern="$2"

  # export only if we haven't already got this dir in the search path
  if [[ ${!varName-} == *"$absPattern"* ]]; then return; fi

  # if the path variable has not yet been set, initialize it to ";;"
  # this is a magic value that will be replaced by the default,
  # allowing relative modules to be used even when there are system modules.
  if [[ ! -v "${varName}" ]]; then export "${varName}=;;"; fi

  # export only if the folder contains lua files
  shopt -s globstar

  local adjustedPattern="${absPattern/\?/\*\*\/\*}"
  for _file in $adjustedPattern; do
    export "${varName}=${!varName:+${!varName};}${absPattern}"
    shopt -u globstar
    return;
  done
  shopt -u globstar
}

_addToLuaPath() {
  local dir="$1"

  echo "HOOK CALLED for dir $dir"

  if [[ ! -d "$dir" ]]; then
    nix_debug "$dir not a directory abort"
    return 0
  fi

  # set -x
  if [[ -v luaPathsSeen[$dir] ]]; then
  # if [ -n "${luaPathsSeen[$dir]}" ]; then
    return
  fi

  luaPathsSeen["$dir"]=1

  # shellcheck disable=SC2164
  cd "$dir"
  # TODO load pattern
  for pattern in @luapathsearchpaths@; do
    addToLuaSearchPathWithCustomDelimiter LUA_PATH "$PWD/$pattern"
  done

  # LUA_CPATH
  for pattern in @luacpathsearchpaths@; do
    addToLuaSearchPathWithCustomDelimiter LUA_CPATH "$PWD/$pattern"
  done

  addToSearchPath program_PATH "$dir"/bin

  # Inspect the propagated inputs (if they exist) and recur on them.
  local prop="$dir/nix-support/propagated-build-inputs"
  if [ -e "$prop" ]; then
    local new_path
    for new_path in $(cat $prop); do
        _addToLuaPath "$new_path"
    done
  fi

  cd - >/dev/null
}

# Builds environment variables like LUA_PATH and PATH walking through closure
# of dependencies.
buildLuaPath() {
  local luaPath="$1"
  local path

  echo "BUILD_LUA_PATH"

  set -x
  # Create an empty table of paths (see doc on loadFromPropagatedInputs
  # for how this is used). Build up the program_PATH and program_LUA_PATH
  # variables.
  declare -A luaPathsSeen=()
  # shellcheck disable=SC2034
  program_PATH=
  luaPathsSeen["@lua@"]=1
  addToSearchPath program_PATH @lua@/bin
  for path in $luaPath; do
    _addToLuaPath "$path"
    # loadFromPropagatedInputs "$path"
  done
  set +x
}


# Adds the lib and bin directories to the LUA_PATH and PATH variables,
# respectively. Recurses on any paths declared in
# `propagated-native-build-inputs`, while avoiding duplicating paths by
# flagging the directories it has visited in `luaPathsSeen`.
# loadFromPropagatedInputs() {
#   local dir="$1"
#   # Stop if we've already visited here.
#   if [ -n "${luaPathsSeen[$dir]}" ]; then
#     return
#   fi
#   luaPathsSeen[$dir]=1

#   _addToLuaPath "$dir"
#   addToSearchPath program_PATH "$dir"/bin

#   # Inspect the propagated inputs (if they exist) and recur on them.
#   # build-deps
#   local prop="$dir/nix-support/propagated-build-inputs"
#   if [ -e "$prop" ]; then
#     local new_path
#     for new_path in $(cat $prop); do
#       loadFromPropagatedInputs "$new_path"
#     done
#   fi
# }
