{ stdenv, fetchFromGitHub
# , git, autoreconfHook,
# pkgconfig
, bison, flex
, libpcap
, xercesc
, pcre
, cmake
}:

stdenv.mkDerivation rec {
  name = "netbee";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "netgroup-polito";
    repo = "netbee";
    rev = "369d6ee2893b12dd004170cb0d4d66e413737a5d";
    sha256 = "09p88naalkbh33cngrgfdw236iy0q1m5r0q4w3ibjpi4qlaw7iis";
  };

  # TODO compile  src/tools first ?
  # https://github.com/netgroup-polito/netbee
  # TODO revert once my other patch is accepted
  # set it to false => cmakeDir will get overriden
  dontUseCmakeBuildDir = true;
  # we set it to false and do our thing instead
  preConfigure = ''
        mkdir -p build
        cd build
  '';
  dontFixCmake = true;
  cmakeDir="../src";

  # $ sudo apt-get install libpcap-dev libxerces-c2-dev libpcre3-dev flex bison libboost-all-dev
  # https://github.com/CPqD/ofsoftswitch13/wiki/OpenFlow-1.3-Tutorial
  buildInputs = [ cmake bison flex xercesc libpcap pcre.dev ];

  # TODO
  meta = with stdenv.lib; {
    homepage = https://openflowswitch.org;
    description = "Advanced library for packet processing. Includes NetVM, NetPDL, and NetPFL.";
    platforms = platforms.unix;
    license = licenses.lgpl2;
  };

}

