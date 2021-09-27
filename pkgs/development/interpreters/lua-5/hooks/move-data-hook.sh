
echo "Sourcing lua-move-data-folder-hook"

# luarocks write data file in a subfolder rock_dir
# that can't be overriden so we move the content of this folder
# ourself until luarocks is patched to provide a flat structure
moveDataFolderHook() {
    echo "Moving data folder"
    # plenary.nvim-scm-1-rocks/plenary.nvim/scm-1
    # rocks_dir
    luaData="$out/$rocksSubdir/$pname/$version"
    if [ -d "$luaData/" ]; then
        echo "Moving data folder $luaData"
        # rm "$luaData/manifest"

        # seems like more files than `copy_directories` end up in $luaData
        # as a quick hack we just copy the "doc" directory if any
        mv -v "$luaData"/* $out
    fi
}

# if [ -z "${dontMoveDataFolder-}" ]; then
#     echo "Moving data folder"
#     moveDataFolderHook
# fi
preFixupHooks+=(moveDataFolderHook)
