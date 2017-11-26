# This function downloads and unpacks an archive file, such as a zip
# or tar file. This is primarily useful for dynamically generated
# archives, such as GitHub's /archive URLs, where the unpacked content
# of the zip file doesn't change, but the zip file itself may
# (e.g. due to minor changes in the compression algorithm, or changes
# in timestamps).

{ lib, fetchurl, fetchzip, luarocks, ... }:

{ # Optionally move the contents of the unpacked tree up one level.
  # stripRoot ? false
# , url
# , extraPostFetch ? ""
 ... } @ args:

# `overrideDerivation drv f' takes a derivation (i.e., the result
#      of a call to the builtin function `derivation') and returns a new
#      derivation in which the attributes of the original are overridden
#      according to the function `f'.  The function `f' is called with
#      the original derivation attributes.

# move rockspec somewhere else
# runCommand "put-in-git" {
#
# // { stripRoot = true; }
lib.overrideDerivation (fetchzip ({
  # name = "toto"; # args.name or (baseNameOf url);
  # name = args.name; # or (baseNameOf url);
  stripRoot = false;
  keepInTemp = true; # we have extra processing steps to do
  extraPostFetch=''
      echo "FETCHROCK postFetch $PWD"

    # mv $unpack

    # echo "Looking for the rockspec"
    # set -x
    # for i in *; do
    #   if [[ "$i" =~ \.rockspec$ ]]; then
    #     rockspec="$i"
    #     break;
    #   fi
    # done
    # if [ -z "$rockspec" ]; then
    #   echo " could not find rockspec"
    #   exit 1
    # fi

    # echo "rockspec found ='$rockspec'"


    # then we need to strip the root folder see fetchzip code
      # if [ $(ls "$unpackDir" | wc -l) != 1 ]; then
      #   echo "error: zip file must contain a single file or directory."
      #   echo "hint: Pass stripRoot=false; to fetchzip to assume flat list of files."
      #   exit 1
      # fi
      # fn=$(cd "$unpackDir" && echo *)
      # if [ -f "$unpackDir/$fn" ]; then
      #   mkdir $out
      # fi
      # mv "$unpackDir/$fn" "$out"
      '';
    # postFetch=''
    #   echo "POSTFETCH"
    #   '';
} // args))
# Hackety-hack: we actually need unzip hooks, too
(x: {
  nativeBuildInputs = x.nativeBuildInputs++ [luarocks];
  # postFetch = x.postFetch + ''
  #   echo "FETCHROCK postFetch $PWD"

  #   unpackFile "lpeg-1.0.1.tar.gz"
  #   '';
})

