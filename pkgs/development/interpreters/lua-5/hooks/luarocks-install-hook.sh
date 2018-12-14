# Setup hook for luarocks.
echo "Sourcing luarocks-check-hook"

luarockInstallPhase() {
    echo "Executing luarocksInstallPhase"
    runHook preInstall

    # work around failing luarocks test for Write access
    mkdir -p $out

    # luarocks make assumes sources are available in cwd
    # After the build is complete, it also installs the rock.
    # If no argument is given, it looks for a rockspec in the current directory
    # but some packages have several rockspecs in their source directory so
    # we force the use of the upper level since it is
    # the sole rockspec in that folder
    # maybe we could reestablish dependency checking via passing --rock-trees

    # nix_debug "ROCKSPEC $rockspecFilename"
    # nix_debug "cwd: $PWD"
    luarocks make --deps-mode=all --tree=$out ''${rockspecFilename}

    runHook postInstall
    echo "Finished executing luarocksInstallPhase"
}

if [ -z "${dontUseluarocksInstall-}" ] && [ -z "${installInstallPhase-}" ]; then
    echo "Using luarocksInstallPhase"
    preDistPhases+=" luarocksInstallPhase"
fi

