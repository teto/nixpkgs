{ lib
# , buildPythonPackage
, buildPythonApplication
, fetchFromGitHub
, isPy3k
, bash, iperf
, openvswitch
, which
# mnexec
}:

# TODO check for python 2 only !
# https://github.com/mininet/mininet/blob/master/INSTALL
# * A Linux kernel compiled with network namespace support enabled
# * An compatible software switch such as Open vSwitch or the Linux bridge.
buildPythonApplication rec {
  pname = "mininet";
  version = "2.2.2";

  disabled = isPy3k;

  src = fetchFromGitHub {
    owner = "mininet";
    repo = pname;
    rev = version;
    sha256 = "18w9vfszhnx4j3b8dd1rvrg8xnfk6rgh066hfpzspzqngd5qzakg";
  };

  # openvswitch / leave it to the module
  # propagatedBuildInputs = [ bash iperf  ];

  meta = with lib; {
    description = "Parses log files, generates metrics for Graphite and Ganglia";
    license = {
      fullName = "Mininet 2.3.0d1 License";
    };
    homepage = https://github.com/mininet/mininet;
  };
}

