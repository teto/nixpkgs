{ stdenv, lib, fetchFromGitHub
, which
, python
, help2man
}:

# TODO present it as a program if it needs openvswitch
# https://github.com/mininet/mininet/blob/master/INSTALL
  # * A Linux kernel compiled with network namespace support enabled
  # * An compatible software switch such as Open vSwitch or the Linux bridge.
let
  pmn =  python.pkgs.mininet;
in
stdenv.mkDerivation rec {
  name = "mininet-${version}";
  version = "2.2.2";

  src = /home/teto/mininet;
  # src = fetchFromGitHub {
  #   owner = "mininet";
  #   repo = "mininet";
  #   rev = version;
  #   sha256 = "18w9vfszhnx4j3b8dd1rvrg8xnfk6rgh066hfpzspzqngd5qzakg";
  # };

  postPatch=''
    substituteInPlace Makefile \
        --replace 'python setup.py install' ""

    # ideally should be necessary only on utils/m ?
    # exclude examples
    patchShebangs .

  '';
  # makeFlags = [ "DESTDIR=$(out)" "BINDIR=$(out)/bin" ];

  buildInputs = [ help2man ];
  propagatedBuildInputs = [ which pmn ];

  makeFlags= [ "mnexec" "PREFIX=$(out)" ];
  # buildPhase=''
  #   make mnexec
  # '';

  meta = with lib; {
    description = "Parses log files, generates metrics for Graphite and Ganglia";
    license = {
      fullName = "Mininet 2.3.0d1 License";
    };
    homepage = https://github.com/mininet/mininet;
  };
}


