{ stdenv, fetchFromGitHub, git, autoreconfHook, pkgconfig, perl }:

stdenv.mkDerivation rec {
  name = "openflowswitch";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "mininet";
    repo = "openflow";
    # rev = "${version}";
    rev = "9f587fc8e657a248d46b4763cc7e72efaccf8e00";
    sha256 = "0xrxkf0dmc4ydkzd5jggg8yzr99d1qfhfpp66bl4in5avh9fxgva";
  };

  # TODO patch openflow
  patches=[]
  # patch -p1 < $MININET_DIR/mininet/util/openflow-patches/controller.patch
  # replace ./boot.sh
  # le autoreconfHook happens in preConfigurePhases
  # preConfigure= ''
  postUnpack= ''

    # sed -e 's/\(.*\)/	\1 \\/' -e '$s/ \\//')
    touch $sourceRoot/debian/automake.mk
cat $sourceRoot/debian/control.in > $sourceRoot/debian/control

  '';

  buildInputs = [ autoreconfHook git pkgconfig perl ];

  # hardeningDisable = [ "format" ];

  meta = with stdenv.lib; {
    homepage = https://openflowswitch.org;
    description = "Tool to measure IP bandwidth using UDP or TCP";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}

