unpackCmdHooks+=(_trySourceRock)
_trySourceRock() {
    echo "LUAROCKS UNPACK on $curSrc"
    if ! [[ "$curSrc" =~ \.src.rock$ ]]; then return 1; fi
    unzip -qq "$curSrc"
}

