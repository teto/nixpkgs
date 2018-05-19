{ stdenv, fetchFromGitHub, git, autoreconfHook, pkgconfig, perl
, boost
# new package
, netbee
}:

stdenv.mkDerivation rec {
  name = "openflowswitch";
  version = "1.3";

  # inspired from mininet's install.sh
  # src = fetchFromGitHub {
  #   owner = "CPqD";
  #   repo = "ofsoftswitch13";
  #   # rev = "${version}";
  #   rev = "e4322f5fb5ec63f0feaf2ae5ea231251ee3108fb";
  #   sha256 = "183913n4rv78nvm75mrk5bjgxibl74xq8r89cximpkpn1f2vz224";
  # };

  src = /home/teto/ofsoftswitch13;

# --with-rundir
# --with-logdir
  #  this is hack because netbee has no pkgconfig
  # NIX_CFLAGS_COMPILE
  # makeFlags=[ CFLAGS="-I${netbee}/include" ];
  # LDFLAGS="-I${netbee}/include";
  NIX_CFLAGS_COMPILE = "-I${netbee}/include";
  NIX_CFLAGS_LINK = "-L${netbee}/lib ";

  postUnpack= ''
    # sed -e 's/\(.*\)/	\1 \\/' -e '$s/ \\//')
    # to prevent automake: error: cannot open < debian/automake.mk: No such file or directory
    touch $sourceRoot/debian/automake.mk
    cat $sourceRoot/debian/control.in > $sourceRoot/debian/control
  '';

  # netbee
  buildInputs = [ autoreconfHook git pkgconfig perl netbee boost ];

  hardeningDisable = [ "all" ];

  meta = with stdenv.lib; {
    homepage = https://openflowswitch.org;
    description = "Tool to measure IP bandwidth using UDP or TCP";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}

