{ lib, buildPythonApplication, fetchFromGitHub, python_magic, dateutil }:

buildPythonApplication rec {
  pname = "s3cmd";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "s3tools";
    repo = "s3cmd";
    rev = "5834228d5bddde3819a3ae5506dd656b62dfb2d1";
    sha256 = "sha256-MK5yS+GcWOE2pNIr13GnE6j6SMxiiOfWqOPeBJYDL1E=";
  };

  propagatedBuildInputs = [ python_magic dateutil ];

  dontUseSetuptoolsCheck = true;

  meta = with lib; {
    homepage = "https://s3tools.org/s3cmd";
    description = "Command line tool for managing Amazon S3 and CloudFront services";
    license = licenses.gpl2;
    maintainers = [ maintainers.spwhitt ];
  };
}
