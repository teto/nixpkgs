# some dependencies need to be patched
# http://code.nsnam.org/bake/file/c502b48053dc/bakeconf.xml
{ stdenv, fetchFromGitHub, autoreconfHook, libtool, intltool, pkgconfig
, ns-3, gcc
, castxml ? null
# hidden dependency of waf
, ncurses
, python
, lib
, fetchurl
, withManual ? false
, withExamples ? false, openssl ? null, ccnd ? null, iperf ? null
, generateBindings ? false
, ...
}:

let
  # doesn't exist in dce yet, just allows to understand inputs better
  withScripts = true;
  modules = [ "core" "network" "internet" "point-to-point" "fd-net-device"
  "point-to-point-layout" "netanim"]
  ++ lib.optionals withScripts [ "tap-bridge" "mobility" "flow-monitor"]
  ;

  ns3forDce = ns-3.override( { inherit modules; });
  pythonEnv = python.withPackages(ps:
    stdenv.lib.optional withManual ps.sphinx
    ++ lib.optionals generateBindings (with ps;[ pybindgen pygccxml ])
  );

  # need to patch iperf
  # lib.optional withExamples
  iperf-dce = iperf.overrideAttrs(old: {

    # choose correct version ?
    src = fetchurl {
      url = http://sourceforge.net/projects/iperf/files/iperf-2.0.5.tar.gz;
      sha256 = "0nr6c81x55ihs7ly2dwq19v9i1n6wiyad1gacw3aikii0kzlwsv3";
    };
    # TODO apply patch
    # patchPhase
    patches = dce + "/utils/iperf_4_dce.patch";
  }).override { stdenv=dceStdenv; };

  # TODO write a dce env
  dceStdenv = stdenv.override rec {
    #  -fuse-ld=gold
    # NIX_CFLAGS_LINK = toString (args.NIX_CFLAGS_LINK or "") + " -rdynamic -pie ";
    # NIX_LDFLAGS=
    NIX_CFLAGS="-fPIC -U_FORTIFY_SOURCE ";
    CXXFLAGS=NIX_CFLAGS;
    NIX_LDFLAGS="-rdynamic -pie";
  };


  # define here
  dce = stdenv.mkDerivation rec {
  name    = "${pname}-${version}";
  pname   = "direct-code-execution";
  version = "1.10";

  src = fetchFromGitHub {
    owner  = "direct-code-execution";
    repo   = "ns-3-dce";
    rev    = version;
    sha256 = "1mvn0z1vl4j9drl3dsw2dv0pppqvj29d2m07487dzzi8cbxrqj36";
  };

  buildInputs = [ ns3forDce gcc pythonEnv ]
    ++ lib.optionals generateBindings [ castxml ncurses ]
    ++ lib.optionals withExamples [ openssl iperf-dce ]
    ;

  nativeBuildInputs = [ pkgconfig ];

  doCheck = true;

  configurePhase = ''
    runHook preConfigure

    ${pythonEnv.interpreter} ./waf configure --prefix=$out \
    --with-ns3=${ns3forDce} --with-python=${pythonEnv.interpreter} \
      ${stdenv.lib.optionalString (!withExamples) "--disable-examples "} ${stdenv.lib.optionalString (!doCheck) " --disable-tests" };

    runHook postConfigure
  '';

  buildPhase=''
    ${pythonEnv.interpreter} ./waf build
  '';

  hardeningDisable = [ "all" ];

  meta = {
    homepage = https://www.nsnam.org/overview/projects/direct-code-execution;
    license = stdenv.lib.licenses.gpl3;
    description = "Run real applications/network stacks in the simulator ns-3";
    platforms = with stdenv.lib.platforms; unix;
  };
};
in
  dce
