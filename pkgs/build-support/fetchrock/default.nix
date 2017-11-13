# This function downloads and unpacks an archive file, such as a zip
# or tar file. This is primarily useful for dynamically generated
# archives, such as GitHub's /archive URLs, where the unpacked content
# of the zip file doesn't change, but the zip file itself may
# (e.g. due to minor changes in the compression algorithm, or changes
# in timestamps).

{ lib, fetchurl, fetchzip, luarocks }:

{ # Optionally move the contents of the unpacked tree up one level.
  stripRoot ? false
# , url
# , extraPostFetch ? ""
, ... } @ args:

# // { stripRoot = true; }
lib.overrideDerivation (fetchzip args)
# Hackety-hack: we actually need unzip hooks, too
(x: {nativeBuildInputs = x.nativeBuildInputs++ [luarocks];})

