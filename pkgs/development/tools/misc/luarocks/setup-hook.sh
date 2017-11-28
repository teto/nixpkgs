unpackCmdHooks+=(_trySourceRock)
_trySourceRock() {

    echo "LUAROCKS unpack on $curSrc"
    if ! [[ "$curSrc" =~ \.src.rock$ ]]; then return 1; fi
    echo "luarocks hook attempts to unpack"

    # export LUAROCKS_CONFIG=
    echo PWD=$PWD
    echo out=$out
    export PATH=${unzip}/bin:$PATH
    # echo $PATH
    # unzip --version
    # luarocks expects a clean <name>.rock.spec name to be the package name
    # so we have to strip the hash
    renamed="$(stripHash $curSrc)"
    cp -v "$curSrc" "$renamed"
    luarocks unpack --verbose --force "$renamed"

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

