{ stdenv, buildPackages, hostPlatform, fetchFromGitHub, perl, buildLinux, ... } @ args:

with stdenv.lib;

let
  version = "4.16.7";
  revision = "a";
  sha256 = "1kdy3sqrn161hm5avhk3nd75p07a21ja0rzar3ybibh1bl2mc6zq";

  modVersion = "${version}-hardened";
in
buildLinux (args // {
  inherit modVersion;

  version = "${version}-${revision}";

  src = fetchFromGitHub {
    inherit sha256;
    owner = "copperhead";
    repo = "linux-hardened";
    rev = "${version}.${revision}";
  };
} // (args.argsOverride or {}))
