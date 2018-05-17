{ stdenv, fetchFromGitHub, git, autoreconfHook, pkgconfig }:

stdenv.mkDerivation rec {
  name = "netbee";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "netgroup-polito";
    repo = "netbee";
    rev = "9f587fc8e657a248d46b4763cc7e72efaccf8e00";
    sha256 = "0xrxkf0dmc4ydkzd5jggg8yzr99d1qfhfpp66bl4in5avh9fxgva";
  };

  # $ sudo apt-get install libpcap-dev libxerces-c2-dev libpcre3-dev flex bison libboost-all-dev
  # https://github.com/CPqD/ofsoftswitch13/wiki/OpenFlow-1.3-Tutorial

  # TODO
  meta = with stdenv.lib; {
    homepage = https://openflowswitch.org;
    description = "Tool to measure IP bandwidth using UDP or TCP";
    platforms = platforms.unix;
    license = licenses.mit;
  };

}

