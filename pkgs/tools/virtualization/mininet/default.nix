{ stdenv, lib, fetchFromGitHub
, which
, python
, help2man
, withDoc ? false, doxygen
# for pdflatex
# , texlive.combined.scheme-minimal pdflatex
, texlive
}:

let
  pyEnv = python.withPackages(ps: ([ ps.setuptools ]
    ++ lib.optional withDoc ps.doxypypy));
in
stdenv.mkDerivation rec {
  pname = "mininet";
  version = "2.3.0d6";

  outputs = [ "out" "py" ];

  src = fetchFromGitHub {
    owner = "mininet";
    repo = "mininet";
    rev = version;
    sha256 = "0wc6gni9dxj9jjnw66a28jdvcfm8bxv1i776m5dh002bn5wjcl6x";
  };

  buildFlags = [ "mnexec" ];
  makeFlags = [ "PREFIX=$(out)" ];

  pythonPath = [ python.pkgs.setuptools ];

  nativeBuildInputs = [ help2man ] ++ lib.optionals withDoc [
    doxygen
    texlive.combined.scheme-full
  ];
  buildInputs = [ pyEnv which ];

  installTargets = [ "install-mnexec" "install-manpages" ];

  preInstall = ''
    mkdir -p $out $py
    # without --root, install fails
    ${pyEnv.interpreter} setup.py install --root="/" --prefix=$py
  '';

  doCheck = false;


  meta = with lib; {
    description = "Emulator for rapid prototyping of Software Defined Networks";
    requiredKernelConfig = [ (kernel.isEnabled "NETNS") ];
    license = {
      fullName = "Mininet 2.3.0d6 License";
    };
    platforms = platforms.linux;
    homepage = "https://github.com/mininet/mininet";
    maintainers = with maintainers; [ teto ];
  };
}
