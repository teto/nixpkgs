# some dependencies need to be patched
# http://code.nsnam.org/bake/file/c502b48053dc/bakeconf.xml
{ stdenv
, fetchFromGitHub
, pkgconfig
, ns-3
, wafHook
, castxml ? null
  # hidden dependency of waf
, ncurses
, python
, lib
, fetchurl
, withManual ? false
  # while in theory we could disable it, it won't build (yet) without the examples
, withExamples ? true
, openssl ? null
  # generate bindings
, pythonSupport ? false
, ns3modules ? [
    "core"
    "network"
    "internet"
    "point-to-point"
    "fd-net-device"
    "point-to-point-layout"
    "netanim"
    "tap-bridge"
    "mobility"
    "flow-monitor"
  ]
}:

let
  dce-version = "1.10";

  wafHook3 = wafHook.override ({ inherit python; });

  ns3forDce = ns-3.override ({ inherit python; modules = ns3modules; });

  pythonEnv = python.withPackages (
    ps:
      lib.optional withManual ps.sphinx
      ++ lib.optionals pythonSupport (with ps;[ pybindgen pygccxml ])
  );

  dce = stdenv.mkDerivation rec {
    pname = "direct-code-execution";
    version = dce-version;

    outputs = [ "out" ] ++ lib.optional pythonSupport "py";

    src = fetchFromGitHub {
      owner = "direct-code-execution";
      repo = "ns-3-dce";
      rev = "dce-${version}";
      sha256 = "0f2g47mql8jjzn2q6lm0cbb5fv62sdqafdvx5g8s3lqri1sca14n";
      name = "dce";
    };

    nativeBuildInputs = [ wafHook3 pkgconfig ];

    buildInputs = [ ns3forDce pythonEnv ]
    ++ lib.optionals pythonSupport [ castxml ncurses ]
    ++ lib.optionals withExamples [ openssl ]
    ;

    doCheck = true;

    # patchPhase = ''
    #   patchShebangs test.py
    # '';

    # "--prefix=$out"
    wafConfigureFlags = with stdenv.lib; [
      "--with-ns3=${ns3forDce}"
      "--with-python=${pythonEnv.interpreter}"
    ]
    ++ optional (!withExamples) "--disable-examples"
    ++ optional (!doCheck) " --disable-tests"
    ;

    buildPhase = ''
      runHook preBuild
      ${pythonEnv.interpreter} ./waf build
      runHook postBuild
    '';

    hardeningDisable = [ "all" ];

    # shellHook= stdenv.lib.optionalString withExamples ''
    #   export DCE_PATH=${iperf-dce}/bin
    # '';

    meta = with stdenv.lib; {
      homepage = "https://www.nsnam.org/overview/projects/direct-code-execution";
      license = licenses.gpl3;
      description = "Run real applications/network stacks in the simulator ns-3";
      platforms = platforms.unix;
      maintainers = with maintainers; [ teto ];
    };
  };
in
dce
