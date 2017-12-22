{ stdenv
, fetchFromGitHub
, python }:

with python.pkgs;

buildPythonApplication rec {
  name = "${pname}-${version}";
  pname = "exch";
  version = "0.2";

  # src = fetchPypi {
  #   inherit pname version;
  #   sha256 = "1kxxhcxwscyx2mjyzbrw3n4a9lyks5vm4iq31jl0bmnda1h0z4qk";
  # };

  src = fetchFromGitHub {
    repo="exch";
    owner= "anshulc95";
    rev="4db3b42020fd5bd63eaf693963debbf174df629f";
    sha256 = "1s53kbj8ws4imnvxi8szd62wk7gimx9afgv3pyr4y0czjm5n6wfs";
  };

  propagatedBuildInputs = [
    click
    requests
  ];

  # buildInputs = [   ];
  doCheck=false;

  checkInputs = [ tox pytest coverage];

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
