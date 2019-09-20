# some dependencies need to be patched
# http://code.nsnam.org/bake/file/c502b48053dc/bakeconf.xml
{ stdenv, fetchFromGitHub, autoreconfHook, libtool, intltool, pkgconfig
, ns-3
, wafHook
, castxml ? null
# hidden dependency of waf
, ncurses
, python
, lib
, fetchurl
, withManual ? false
, withExamples ? false, openssl ? null, ccnd ? null, iperf2 ? null
# shall we generate bindings
, pythonSupport ? false
, ns3modules ? [ "core" "network" "internet" "point-to-point" "fd-net-device"
  "point-to-point-layout" "netanim" "tap-bridge" "mobility" "flow-monitor"]
, ...
}:

let
  dce-version = "1.10";

  ns3forDce = ns-3.override( { inherit python; modules = ns3modules; });

  pythonEnv = python.withPackages(ps:
    stdenv.lib.optional withManual ps.sphinx
    ++ lib.optionals pythonSupport (with ps;[ pybindgen pygccxml ])
  );

  dce = stdenv.mkDerivation rec {
    pname   = "direct-code-execution";
    version = dce-version;

    outputs = [ "out" ] ++ lib.optional pythonSupport "py";

    src = fetchFromGitHub {
        owner  = "direct-code-execution";
        repo   = "ns-3-dce";
        rev    = "dce-${version}";
        sha256 = "0f2g47mql8jjzn2q6lm0cbb5fv62sdqafdvx5g8s3lqri1sca14n";
        name   = "dce";
    };

    # sourceRoot = "dce";

    buildInputs = [ ns3forDce pythonEnv ]
      ++ lib.optionals pythonSupport [ castxml ncurses ]
      ++ lib.optionals withExamples [ openssl ]
      ;

    nativeBuildInputs = [ pkgconfig ];

    doCheck = true;

    patchPhase = ''
      patchShebangs test.py
    '';

    wafConfigureFlags = with stdenv.lib; [
      "--with-ns3=${ns3forDce}"

    ]
    ++ optional (!withExamples) "--disable-examples"
    ++ optional (!doCheck) " --disable-tests"
    ;

    configurePhase = ''
      runHook preConfigure

      ${pythonEnv.interpreter} ./waf configure --prefix=$out \
      --with-python=${pythonEnv.interpreter} \
      runHook postConfigure
    '';

    buildPhase=''
      ${pythonEnv.interpreter} ./waf build
    '';

    hardeningDisable = [ "all" ];

    # shellHook= stdenv.lib.optionalString withExamples ''
    #   export DCE_PATH=${iperf-dce}/bin
    # '';

    meta = {
      homepage = https://www.nsnam.org/overview/projects/direct-code-execution;
      license = stdenv.lib.licenses.gpl3;
      description = "Run real applications/network stacks in the simulator ns-3";
      platforms = with stdenv.lib.platforms; unix;
    };
  };
in
  dce
