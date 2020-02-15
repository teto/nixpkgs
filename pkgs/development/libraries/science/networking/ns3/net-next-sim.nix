{
  stdenv
  , fetchFromGitHub
  , python
  , linux
}:
# { stdenv, buildPackages, fetchurl, fetchFromGitHub, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

# explanation at http://direct-code-execution.github.io/net-next-sim/
# buildLinux (args // rec {
#   # version = "4.19.100";
#   version = "unstable";

#   pname = "libos";

#   src = fetchFromGitHub {
#     url = https://github.com/libos-nuse/net-next-nuse;
#     owner = "libos-nuse";
#     repo = "net-next-nuse";
#     rev = "25a9dd363ccf75cc3c58756049c4864d9bc88f9b";
#     sha256 = "0f3g47mql8jjzn2q6lm0cbb5fv62sdqafdvx5g8s3lqri1sca14n";
#   };

#   # modDirVersion needs to be x.y.z, will automatically add .0 if needed
#   # modDirVersion = if (modDirVersionArg == null) then concatStringsSep "." (take 3 (splitVersion "${version}.0")) else modDirVersionArg;
#   # # branchVersion needs to be x.y
#   # extraMeta.branch = versions.majorMinor version;
# } // (args.argsOverride or {}))

stdenv.mkDerivation {
  version = "unstable";
  pname = "libos";

  src = fetchFromGitHub {
    # url = https://github.com/libos-nuse/net-next-nuse;
    owner = "libos-nuse";
    repo = "net-next-nuse";
    rev = "25a9dd363ccf75cc3c58756049c4864d9bc88f9b";
    sha256 = "sha256-EE6DlcTqGj7c0vLbp5KHTO5QFxiGc60oViDVbLsJYSM=";
  };

  inherit (linux) buildInputs nativeBuildInputs;


  configurePhase = ''
    make defconfig ARCH=lib
  '';

  buildPhase = ''
    make library ARCH=lib
  '';

  checkPhase = ''
    make testbin -C arch/lib/test
    make test ARCH=lib
  '';
}
