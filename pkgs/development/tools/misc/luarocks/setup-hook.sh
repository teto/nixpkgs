unpackCmdHooks+=(_trySourceRock)
_trySourceRock() {

    echo "LUAROCKS unpack on $curSrc"
    echo "ARGS:"
    echo "$@"
    if ! [[ "$curSrc" =~ \.src.rock$ ]]; then return 1; fi
    echo "luarocks hook attempts to unzip"
    unzip -qq "$curSrc"

    echo "LUAROCKS UNPACK on $curSrc"
}

