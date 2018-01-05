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
, libarchive
# pygccxml
# todo to make them accessible
, musl-frankenlibc
, lkl
}:

let
  # lkl-franken = lkl.overrideAttrs(;
  lkl_src = /home/teto/lkl;
  # musl_src = ;
in
stdenv.mkDerivation rec {
  name    = "${pname}-${version}";
  pname   = "frankenlibc";
  version = "20171220";

  # src = fetchFromGitHub {
  #   owner  = "teto";
  #   repo   = "frankenlibc";
  #   rev    = "98c005807ba79b6d7027860d523c7e5f77001018";
  #   sha256 = "1myq0nbhrx2zna0sjazbyk4i0f0hmv3dnvdl9j1hqnfdj4fgj9zr";
  #   fetchSubmodules=true;
  # };
  src = /home/teto/frankenlibc;

  buildInputs = []
    # ++ stdenv.lib.optionals
    ;

  # -O2
  # NIX_CFLAGS=""
  # disable hardening else the CC wrapper adds fucking flags that get in the way
  hardeningDisable = if (lkl?hardeningDisable) then lkl.hardeningDisable else [ "all" ];

  # libarchive-dev
  nativeBuildInputs = [ git pkgconfig fuse zlib libarchive.dev ] ++ lkl.nativeBuildInputs;
  # autoreconfHook libtoog


  # CC wrapper must end up in rump/bin/
  # can use RUMP_VERBOSE=1
  postPatch=''
    # takes too long with submodules
    patchShebangs .

    # some scripts will generate this
    # patchShebangs rump/
    '';

  # preBuild=''
  # # ln -s ${musl-frankenlibc.src} musl
  #   # ln -s ${lkl.src} linux
  #   '';

  # export LKL_SRCDIR="${lkl}"
  buildPhase = ''
    set -x
    # else it fails to find
    # TODO set RELEASEDIR
    export HOST_SH="${bash}/bin/sh"
    export TOOLDIR="$PWD/src/tools"
    # TODO change it ?
    export RELEASEDIR="$PWD/releasedir"
    export TMPDIR=/tmp
    # TODO need to patch it

    # TODO try to use lkl patched sources at least ?
    # export LKL_SRCDIR=/tmp
    echo "hello wrold"

    # -k rumpkernel type = linux
    # -d installFolder
    # paltform linux
    #  -d $out
    # ./build.sh -q -k linux linux notests
    # the platform is checked  in PWD/platforms
    ./build.sh linux notests
    # -b $out/bin
    set +x
    '';

	# printf "Usage: $0 [-h] [options] [platform]\n"
	# printf "supported options:\n"
	# printf "\t-k: type of rump kernel [netbsd|linux]. default linux\n"
	# printf "\t-L: libraries to link eg net_netinet,net_netinet6. default all\n"
	# printf "\t-m: hardcode rump memory limit. default from env or unlimited\n"
	# printf "\t-M: thread stack size. default: 64k\n"
	# printf "\t-p: huge page size to use eg 2M or 1G\n"
	# printf "\t-r: release build, without debug settings\n"
	# printf "\t-s: location of source tree.  default: PWD/rumpsrc\n"
	# printf "\t-o: location of object files. default PWD/rumpobj\n"
	# printf "\t-d: location of installed files. default PWD/rump\n"
	# printf "\t-b: location of binaries. default PWD/rump/bin\n"
	# printf "\tseccomp|noseccomp: select Linux seccomp (default off)\n"
	# printf "\texecveat: use new linux execveat call default off)\n"
	# printf "\tcapsicum|nocapsicum: select FreeBSD capsicum (default on)\n"
	# printf "\tdeterministic: make deterministic\n"
	# printf "\tnotests: do not run tests\n"
	# printf "\tnotools: do not build extra tools\n"
	# printf "\tclean: clean object directory first\n"
	# printf "Other options are passed to buildrump.sh\n"
	# printf "\n"
	# printf "Supported platforms are currently: linux, netbsd, freebsd, qemu-arm, spike\n"
	# exit 1


    # mv from rumprun ?
  installPhase=''
    mkdir -p $out/bin
    cp -r bin $bin
  '';

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

