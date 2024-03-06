# set -e

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
  # delete longest match starting from the lua placeholder '?'
  local topDir="${absPattern%%\?*}"

  # export only if we haven't already got this dir in the search path
  if [[ ${!varName-} == *"$absPattern"* ]]; then return; fi

  # export only if the folder contains lua files
  shopt -s globstar
  for _file in "$topDir"/**.lua; do
    export "${varName}=${!varName:+${!varName};}${absPattern}"
    return;
  done

  # if the path variable has not yet been set, initialize it to ";;"
  # this is a magic value that will be replaced by the default,
  # allowing relative modules to be used even when there are system modules.
  if [[ -v "${varName}" ]]; then export "${varName}=;;"; fi

}

addToLuaPath() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    nix_debug "$dir not a directory abort"
    return 0
  fi
  cd "$dir"
  for pattern in @luapathsearchpaths@; do
    addToLuaSearchPathWithCustomDelimiter LUA_PATH "$PWD/$pattern"
  done

  # LUA_CPATH
  for pattern in @luacpathsearchpaths@; do
    addToLuaSearchPathWithCustomDelimiter LUA_CPATH "$PWD/$pattern"
  done
  cd - >/dev/null
}

addEnvHooks "$hostOffset" addToLuaPath
