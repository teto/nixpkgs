{ stdenv, lib, fetchFromGitHub
, which
# only supports python2
, python
, help2man
}:

# https://github.com/mininet/mininet/blob/master/INSTALL
  # * A Linux kernel compiled with network namespace support enabled
  # * An compatible software switch such as Open vSwitch or the Linux bridge.
# let
#   pmn =  python.pkgs.mininet;
# in
stdenv.mkDerivation rec {
  name = "mininet-${version}";
  version = "2.2.2";

  propagatedBuildOutputs = "out bin py";

  outputs = [ "bin" "dev" "out" "man" "doc" "py" ];

  src = /home/teto/mininet;
  # src = fetchFromGitHub {
  #   owner = "mininet";
  #   repo = "mininet";
  #   rev = version;
  #   sha256 = "18w9vfszhnx4j3b8dd1rvrg8xnfk6rgh066hfpzspzqngd5qzakg";
  # };

  # TODO move it to an optional output ?
  postPatch=''
    # substituteInPlace Makefile \
    #     --replace 'python setup.py install' ""

    # ideally should be necessary only on utils/m ?
    # exclude examples
    patchShebangs .

  '';

  postBuild= ''

    ${python.interpreter} setup.py install --prefix=$py
  '';

  # makeFlags = [ "DESTDIR=$(out)" "BINDIR=$(out)/bin" ];
  # installFlags = lib.optionalString pythonSupport
  #   ''pythondir="$(py)/lib/${python.libPrefix}/site-packages"'';

  buildInputs = [ help2man ];
  # TODO do we need pmn ?
  propagatedBuildInputs = [ which  ];

  makeFlags= [ "mnexec" "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)" "PYTHONDIR=$py" ];
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


