{ stdenv, fetchFromGitHub
, fetchgit
, fetchgitLocal
# , pkgconfig, cmake, intltool, gettext
# , dbus, gtk2, gtk3, qt4, extra-cmake-modules
, buildPythonApplication
}:

# stdenv.mkDerivation
buildPythonApplication rec {
  version = "0.3.1";
  name = "tegaki-python";
  # name = "${pname}-${version}";

  # src = fetchFromGitHub {
  #   owner = "tegaki";
  #   repo = "tegaki";
  #   rev = "v${version}";
  #   sha256 = "09mw2if9p885phbgah5f95q3fwy7s5b46qlmpxqyzfcnj6g7afr5";
  # };
  src = fetchgitLocal /home/teto/tegaki;
  # {
  #   url = file:///home/teto/tegaki;
  #   rev = "master";
  #   sha256 = "09mw2if9p885phbgah5f95q3fwy7s5b46qlmpxqyzfcnj6g7afr5";
  # };
  sourceRoot = "${src.name}/tegaki-python";

  # src = /home/teto/tegaki/tegaki-python;

  # propagatedBuildInputs = [ tegaki ];

  # postPatch = ''
  #   substituteInPlace src/frontend/qt/CMakeLists.txt \
  #     --replace $\{QT_PLUGINS_DIR} $out/lib/qt4/plugins
  # '';

  # nativeBuildInputs = [ cmake extra-cmake-modules intltool pkgconfig ];

  # buildInputs = [
  #   enchant gettext isocodes icu libpthreadstubs libXau libXdmcp libxkbfile
  #   libxkbcommon libxml2 dbus cairo gtk2 gtk3 pango qt4
  # ];
  meta = with stdenv.lib; {
    description = "Japanese handwriting recognition";
    homepage = http://tegaki.org/;
    license = licenses.lgpl21;
    platforms = platforms.unix;
    maintainers = [ maintainers.teto ];
  };
}


