{ stdenv, fetchFromGitHub, autoreconfHook, libtool, intltool, pkgconfig
, ns-3, gcc
, castxml ? null
# hidden dependency of waf
, ncurses
, python
, lib
, withManual ? false
, withExamples ? false
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
in
stdenv.mkDerivation rec {
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
    ++ lib.optionals generateBindings [ castxml ncurses ];

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
}
