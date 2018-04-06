{ stdenv, fetchFromGitHub, autoreconfHook, libtool, intltool, pkgconfig
, ns-3, gcc
, castxml ? null
, python
, lkl
# , musl-frankenlibc
# pygccxml
, lib
, withDoc ? false
, withManual ? false
, withExamples ? false
, withBindings ? false
, ...
}:

let
  # doesn't exist in dce yet, just allows to understand inputs better
  withScripts = true;
  modules = [ "core" "network" "internet" "point-to-point" "fd-net-device"
  "point-to-point-layout" "netanim"]
  ++ lib.optionals withScripts [ "tap-bridge" "mobility" "flow-monitor"]
  ++ lib.optionals withExamples []
  ;

  # ns3forDce = ns-3.override( { inherit modules; });
  ns3forDce = ns-3;

  pythonEnv = python.withPackages (ps: with ps; [ pygccxml ]);
in
stdenv.mkDerivation rec {
  name    = "${pname}-${version}";
  pname   = "direct-code-execution";
  version = "1.10";

  src = /home/teto/dce;
  # src = fetchFromGitHub {
  #   owner  = "direct-code-execution";
  #   repo   = "ns-3-dce";
  #   rev    = version;
  #   sha256 = "1mvn0z1vl4j9drl3dsw2dv0pppqvj29d2m07487dzzi8cbxrqj36";
  # };

  buildInputs = [ ns3forDce gcc  pythonEnv  ]
    # ++ stdenv.lib.optionals
    ;

  nativeBuildInputs = [ pkgconfig ];

  doCheck = false;

  # TODO set --with-python if bindings enabled
  configurePhase = ''
    runHook preConfigure

    echo "rerun with CXXFLAGS=-I/home/teto/lkl/tools/lkl/include"
    ${python.interpreter} ./waf configure --prefix=$out \
    --with-ns3=${ns3forDce} --with-python=${pythonEnv.interpreter} \
      ${stdenv.lib.optionalString (!withExamples) "--disable-examples "} ${stdenv.lib.optionalString (!doCheck) " --disable-tests" }

    runHook postConfigure
  '';

  buildPhase=''
    ./waf build
  '';

  hardeningDisable = [ "all" ];

  meta = {
    homepage = https://www.nsnam.org/overview/projects/direct-code-execution;
    license = stdenv.lib.licenses.gpl3;
    description = "Run real applications/network stacks in the simulator ns-3";
    platforms = with stdenv.lib.platforms; unix;
  };
}
