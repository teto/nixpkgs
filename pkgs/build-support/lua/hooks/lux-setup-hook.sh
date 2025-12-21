luxSetupPostUnpackHook() {
    echo "Executing luxSetupPostUnpackHook"

#     eval "${luxDepsHook-}"
#
#     # Some lux builds include build hooks that modify their own vendor
#     # dependencies. This copies the vendor directory into the build tree and makes
#     # it writable. If we're using a tarball, the unpackFile hook already handles
#     # this for us automatically.
#     if [ -z $luxVendorDir ]; then
#         if [ -d "$luxDeps" ]; then
#             local dest=$(stripHash "$luxDeps")
#             cp -Lr --reflink=auto -- "$luxDeps" "$dest"
#             chmod -R +644 -- "$dest"
#         else
#             unpackFile "$luxDeps"
#         fi
#         export luxDepsCopy="$(realpath "$(stripHash $luxDeps)")"
#     else
#         luxDepsCopy="$(realpath "$(pwd)/$sourceRoot/${luxRoot:+$luxRoot/}${luxVendorDir}")"
#     fi
#
#     if [ ! -d .lux ]; then
#         mkdir .lux
#     fi
#
#     config="$luxDepsCopy/.lux/config.toml"
#     if [[ ! -e $config ]]; then
#       config=@defaultConfig@
#     fi;
#
#     tmp_config=$(mktemp)
#     substitute $config $tmp_config \
#       --subst-var-by vendor "$luxDepsCopy"
#     cat ${tmp_config} >> .lux/config.toml
#
#     cat >> .lux/config.toml <<'EOF'
#     @luxConfig@
# EOF

    echo "Finished luxSetupPostUnpackHook"
}

# After unpacking and applying patches, check that the lux.lock matches our
# src package. Note that we do this after the patchPhase, because the
# patchPhase may create the lux.lock if upstream has not shipped one.
luxSetupPostPatchHook() {
    echo "Executing luxSetupPostPatchHook"

    luxDepsLockfile="$luxDepsCopy/lux.lock"
    srcLockfile="$(pwd)/${luxRoot:+$luxRoot/}lux.lock"

    echo "Validating consistency between $srcLockfile and $luxDepsLockfile"
    if ! @diff@ $srcLockfile $luxDepsLockfile; then

      # If the diff failed, first double-check that the file exists, so we can
      # give a friendlier error msg.
      if ! [ -e $srcLockfile ]; then
        echo "ERROR: Missing lux.lock from src. Expected to find it at: $srcLockfile"
        echo "Hint: You can use the luxPatches attribute to add a lux.lock manually to the build."
        exit 1
      fi

      if ! [ -e $luxDepsLockfile ]; then
        echo "ERROR: Missing lockfile from lux vendor. Expected to find it at: $luxDepsLockfile"
        exit 1
      fi

      echo
      echo "ERROR: luxHash or luxSha256 is out of date"
      echo
      echo "lux.lock is not the same in $luxDepsCopy"
      echo
      echo "To fix the issue:"
      echo '1. Set luxHash/luxSha256 to an empty string: `luxHash = "";`'
      echo '2. Build the derivation and wait for it to fail with a hash mismatch'
      echo '3. Copy the "got: sha256-..." value back into the luxHash field'
      echo '   You should have: luxHash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";'
      echo

      exit 1
    fi

    unset luxDepsCopy

    echo "Finished luxSetupPostPatchHook"
}

if [ -z "${dontluxSetupPostUnpack-}" ]; then
  postUnpackHooks+=(luxSetupPostUnpackHook)
fi

if [ -z ${luxVendorDir-} ]; then
  postPatchHooks+=(luxSetupPostPatchHook)
fi


