{ lib, fetchFromGitHub

, bash, iperf
, openvswitch
, which
# mnexec
}:

# https://github.com/mininet/mininet/blob/master/INSTALL
  # * A Linux kernel compiled with network namespace support enabled
  # * An compatible software switch such as Open vSwitch or the Linux bridge.
stdenv.mkDerivation rec {
  pname = "mininet";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "mininet";
    repo = pname;
    rev = version;
    sha256 = "18w9vfszhnx4j3b8dd1rvrg8xnfk6rgh066hfpzspzqngd5qzakg";
  };

  propagatedBuildInputs = [ bash  iperf openvswitch ];

  meta = with lib; {
    description = "Parses log files, generates metrics for Graphite and Ganglia";
    license = {
      fullName = "Mininet 2.3.0d1 License";
    };
    homepage = https://github.com/mininet/mininet;
  };
}


