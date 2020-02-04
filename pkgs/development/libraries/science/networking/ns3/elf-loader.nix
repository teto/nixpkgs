{
  stdenv
, fetchhg
, fetchFromGitHub
, python # needed for extract-system-config.py:
}:

stdenv.mkDerivation {

  pname = "elf-loader";
  version = "unstable-";

  src = fetchFromGitHub {
    owner = "teto";
    repo = "elf-loader";
    rev = "5d43d4e74c010799c9d70e943e56403cc6757455";
    sha256 = "sha256-VxzjezbeRBpSwxwo5p7JwGwbVPA9p1IClB3a36+1hM8=";


  };

  # src = fetchhg {
  #   url = http://code.nsnam.org/thehajime/elf-loader;
  #   rev = "213835f32c54";
  #   sha256 = "sha256-qEVUqkEsci88/pj7sJtiRcp6c4YEv3iyIs89XIBqRNU=";
  # };
  preConfigure = ''
    patchShebangs extract-system-config.py
  '';

  # nativeBuildInputs = [ python ];
  buildInputs = [ python ];
  # makeFlags
# DEBUG+=-DMALLOC_DEBUG_ENABLE

}
