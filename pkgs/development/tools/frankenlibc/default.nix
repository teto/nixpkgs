{ stdenv
, fetchFromGitHub
# autoreconfHook, libtool, intltool
, pkgconfig
, git
# , musl-franken
# 2 or 3
, fuse
, bash
, zlib
, lkl
, libarchive
# pygccxml
}:

stdenv.mkDerivation rec {
  name    = "${pname}-${version}";
  pname   = "frankenlibc";
  version = "20171220";

  # src = fetchFromGitHub {
  #   owner  = "direct-code-execution/";
  #   repo   = "ns-3-dce";
  #   rev    = "${version}";
  #   sha256 = "1mvn0z1vl4j9drl3dsw2dv0pppqvj29d2m07487dzzi8cbxrqj36";
  # };
  src = /home/teto/frankenlibc;

  buildInputs = []
    # ++ stdenv.lib.optionals
    ;

  # -O2
  # NIX_CFLAGS=""
  # disable hardening else the CC wrapper adds fucking flags that get in the way
  hardeningDisable = [ "all" ];

  # libarchive-dev
  nativeBuildInputs = [ git pkgconfig fuse zlib libarchive.dev ] ++ lkl.nativeBuildInputs;
  # autoreconfHook libtool


  # CC wrapper must end up in rump/bin/
  # can use RUMP_VERBOSE=1
  postPatch=''
    # takes too long with submodules
    patchShebangs .

    # some scripts will generate this
    # patchShebangs rump/
    '';


  buildPhase = ''
    # else it fails to find
    # TODO set RELEASEDIR
    export HOST_SH="${bash}/bin/sh"
    export TOOLDIR="$PWD/src/tools"
    export RELEASEDIR="$PWD/releasedir"
    export TMPDIR=/tmp

    # TODO try to use lkl patched sources at least ?
    export LKL_SRCDIR=/tmp
    echo "hello wrold"

    # -k rumpkernel type = linux
    # paltform linux
    ./build.sh -q -k linux linux notests

    '';

    # mv from rumprun ?
  # installPhase=

  # with-ns3 should be install folder
  doCheck=false;

  checkPhase=''
    make -C tests run
  '';


  meta = {
    homepage = https://www.nsnam.org/overview/projects/direct-code-execution;
    license = stdenv.lib.licenses.gpl3;
    description = "Run real applications/network stacks in the simulator ns-3";
    platforms = with stdenv.lib.platforms; unix;
  };
}

