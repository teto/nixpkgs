{ stdenv, lib, fetchFromGitHub
, which
# only supports python2
, python
, help2man
}:

# https://github.com/mininet/mininet/blob/master/INSTALL
  # * A Linux kernel compiled with network namespace support enabled
  # * An compatible software switch such as Open vSwitch or the Linux bridge.
let
  # pmn =  python.pkgs.mininet;
  pyEnv = python.withPackages(ps: [
    # ps.setuptools
  ]);
in
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
  # might need to remove the MANPAGE from install
  postPatch=''
    # substituteInPlace Makefile \
    #     --replace 'python setup.py install' ""

    # ideally should be necessary only on utils/m ?
    # exclude examples
    # patchShebangs .

  '';

  postBuild= ''

    ${python.interpreter} setup.py install --prefix=$py
  '';

  # makeFlags = [
  #   "DESTDIR=$(out)" "BINDIR=$(out)/bin"
  # ];
  makeFlags= [
    "mnexec"
    "PREFIX=$(out)"
    # hack
    # "PYMN=${version}"
    "VERSION='\"${version}\"'"
    # "PYMN='$(${pyEnv.interpreter} -B bin/mn)'"
  ];

  installFlags = [ "install" "PREFIX=$(out)" "PYTHONDIR=$py"
    "PYTHON=${pyEnv.interpreter}"
  ];

  doCheck = false;
  # installFlags = lib.optionalString pythonSupport
  #   ''pythondir="$(py)/lib/${python.libPrefix}/site-packages"'';
  postInstall=''
    moveToOutput pythondir $py
  '';

  buildInputs = [ help2man pyEnv ];

  # TODO do we need pmn ?
  propagatedBuildInputs = [ which  ];

  # buildPhase=''
  #   make mnexec
  # '';

  meta = with lib; {
    description = "Emulator for rapid prototyping of Software Defined Networks";
    license = {
      fullName = "Mininet 2.3.0d1 License";
    };
    homepage = https://github.com/mininet/mininet;
  };
}


