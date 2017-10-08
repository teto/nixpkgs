
{ stdenv, pkgs, python3Packages }:

with python3Packages;

buildPythonApplication rec {
  name = "${pname}-${version}";
  pname = "exch";
  version = "0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1kxxhcxwscyx2mjyzbrw3n4a9lyks5vm4iq31jl0bmnda1h0z4qk";
  };


  propagatedBuildInputs = [
    click
    requests
  ];
  buildInputs = [ tox pytest coverage ];

  checkPhase = ''
    tox
  '';

  meta = with stdenv.lib; {
    homepage = http://github.com/anshulc9/exch;
    description = "CLI currency converter";
    license = licenses.mit;
    maintainers = with maintainers; [ teto ];
  };
}
