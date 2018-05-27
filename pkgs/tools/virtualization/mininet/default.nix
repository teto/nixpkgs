{ stdenv, lib, fetchFromGitHub
, which
# only supports python2
, python
, help2man
}:

let
  pyEnv = python.withPackages(ps: [ ps.setuptools ]);
in
stdenv.mkDerivation rec {
  name = "mininet-${version}";
  version = "20180628";

  outputs = [ "out" "py" ];

  src = /home/teto/mininet;

  # src = fetchFromGitHub {
  #   owner = "mininet";
  #   repo = "mininet";
  #   rev = "34b1f4161ab7cd8ce5d7c2a04a24dac8533378d9";
  #   sha256 = "1yd8fpycdqfg3zf8wjkvnjq3z4rg98pl8vivg25nqmf8k2c4kc9y";
  # };

  buildFlags = [ "mnexec" ];
  makeFlags = [ "PREFIX=$(out)" ];

  installTargets = [ "install-mnexec" "install-manpages" ];

  preInstall = ''
    mkdir -p $out $py
    # without --root, install fails
    ${pyEnv.interpreter} setup.py install --root="/" --prefix=$py
  '';

  doCheck = false;

  buildInputs = [ python.pkgs.wrapPython which help2man pyEnv ];

  meta = with lib; {
    description = "Emulator for rapid prototyping of Software Defined Networks";
    license = {
      fullName = "Mininet 2.3.0d1 License";
    };
    homepage = https://github.com/mininet/mininet;
    maintainers = with maintainers; [ teto ];
  };
}
