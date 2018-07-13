{ stdenv, buildPackages, hostPlatform, fetchFromGitHub, perl, buildLinux, ... } @ args:

buildLinux (rec {
  mptcpVersion = "0.94";
  modDirVersion = "4.14.24";
  version = "${modDirVersion}-mptcp_v${mptcpVersion}";
  # autoModules= true;

  extraMeta = {
    branch = "4.4";
    maintainers = with stdenv.lib.maintainers; [ teto layus ];
  };

  src = fetchFromGitHub {
    owner = "multipath-tcp";
    repo = "mptcp";
    rev = "v${mptcpVersion}";
    sha256 = "01y3jf5awdxcv6vfpr30n0vaa8w1wgip0whiv88d610550299hkv";
  };

  extraStructuredConfig = with stdenv.lib.kernel; {
    IPV6               = yes;
    MPTCP              = yes;
    IP_MULTIPLE_TABLES = yes;

    # Enable advanced path-managers...
    MPTCP_PM_ADVANCED = yes;
    MPTCP_FULLMESH = yes;
    MPTCP_NDIFFPORTS = yes;
    # ... but use none by default.
    # The default is safer if source policy routing is not setup.
    DEFAULT_DUMMY = yes;
    DEFAULT_MPTCP_PM = "default";

    # MPTCP scheduler selection.
    MPTCP_SCHED_ADVANCED = yes;
    DEFAULT_MPTCP_SCHED = "default";

    # Smarter TCP congestion controllers
    TCP_CONG_LIA = module;
    TCP_CONG_OLIA = module;
    TCP_CONG_WVEGAS = module;
    TCP_CONG_BALIA = module;
  } // (args.extraStructuredConfig or {});
} // args)
