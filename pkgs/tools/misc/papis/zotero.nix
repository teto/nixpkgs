{ lib, fetchFromGitHub, fetchpatch
, python3, xdg_utils
}:

python3.pkgs.buildPythonApplication rec {
  pname = "papis-zotero";
  version = "0.0.3";

  # Missing tests on Pypi
  # src = fetchFromGitHub {
  #   owner = "papis";
  #   repo = pname;
  #   rev = "v${version}";
  #   sha256 = "0sa1hpgjvqkjcmp9bjr27b5m5jg4pfspdc8nf1ny80sr0kzn72hb";
  # };

  src = builtins.fetchGit {
      url = git://github.com/papis/papis-zotero;

  };

  propagatedBuildInputs = with python3.pkgs; [ papis ];

  doCheck = false;
  checkPhase = ''
    HOME=$(mktemp -d) pytest papis tests --ignore tests/downloaders
  '';

  meta = {
    description = "Powerful command-line document and bibliography manager";
    homepage = https://github.com/papis/papis-zotero;
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.teto ];
  };
}

