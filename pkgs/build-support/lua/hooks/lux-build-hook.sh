# shellcheck shell=bash disable=SC2154,SC2164

luxBuildHook() {
    echo "Executing luxBuildHook"

    runHook preBuild

    # Let stdenv handle stripping, for consistency and to not break
    # separateDebugInfo.
    export "lux_PROFILE_${luxBuildType@U}_STRIP"=false

    if [ -n "${buildAndTestSubdir-}" ]; then
        # ensure the output doesn't end up in the subdirectory
        lux_TARGET_DIR="$(pwd)/target"
        export lux_TARGET_DIR

        pushd "${buildAndTestSubdir}"
    fi

    local flagsArray=(
        # "-j" "$NIX_BUILD_CORES"
        # "--offline"
    )

    concatTo flagsArray luxBuildFlags

    which pkg-config
    which lua

    echoCmd 'luxBuildHook flags' "${flagsArray[@]}"
    # TODO pass a tree to work on --tree=$out ?
    set -x
    strace -o log -f @setEnv@ lx --no-progress --verbose "--lua-version=@luaversion@" build "${flagsArray[@]}"

    if [ -n "${buildAndTestSubdir-}" ]; then
        popd
    fi

    runHook postBuild

    echo "Finished luxBuildHook"
}

if [ -z "${dontluxBuild-}" ] && [ -z "${buildPhase-}" ]; then
  buildPhase=luxBuildHook
fi

