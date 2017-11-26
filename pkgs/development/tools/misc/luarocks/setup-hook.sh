unpackCmdHooks+=(_trySourceRock)
_trySourceRock() {

    echo "LUAROCKS unpack on $curSrc"
    echo "ARGS:"
    echo "$@"
    if ! [[ "$curSrc" =~ \.src.rock$ ]]; then return 1; fi
    echo "luarocks hook attempts to unpack"
    # unzip -qq "$curSrc"
    # todo add --force
    luarocks unpack "$curSrc"

    # most likely it will have a tar.gz archive in it
    # unpackFile "*.tar.gz"

    # unpackDir="$PWD"
    #   if [ $(ls "$unpackDir" | wc -l) != 1 ]; then
    #     echo "error: zip file must contain a single file or directory."
    #     echo "hint: Pass stripRoot=false; to fetchzip to assume flat list of files."
    #     exit 1
    #   fi
    #   fn=$(cd "$unpackDir" && echo *)
    #   if [ -f "$unpackDir/$fn" ]; then
    #     mkdir $out
    #   fi

    echo "LUAROCKS UNPACK on $curSrc"
}

