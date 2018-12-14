{ buildPythonPackage, lib, fetchPypi }:

buildPythonPackage rec {
  pname = "python-rofi";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0qbsg7x7qcqrm2b771z8r6f86v3zkafk49yg35xq1lgwl73vimpj";
  };

  # No tests existing
  doCheck = false;

  meta = {
    description = "Create simple GUIs using the Rofi application";
    homepage = https://github.com/bcbnz/python-rofi;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.teto ];
  };
}
