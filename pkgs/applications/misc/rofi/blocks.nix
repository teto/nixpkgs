{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libxkbcommon
, pango
, which
, git
, cairo
, libxcb
, xcbutil
, xcbutilwm
, xcbutilxrm
, xcb-util-cursor
, libstartup_notification
, bison
, flex
, librsvg
, check
}:

stdenv.mkDerivation rec {
  pname = "rofi-blocks";
  version = "unstable-2021-11-28";

  src = fetchFromGitHub {
    owner = "OmarCastro";
    repo = "rofi-blocks";
    rev = version;
    # fetchSubmodules = true;
    sha256 = "03wdy55b3g8p2czb0qydrddyyhj3x037pirnhyqr5qbfczb9a63v";
  };

  # preConfigure = ''
  #   patchShebangs "script"
  #   # root not present in build /etc/passwd
  #   sed -i 's/~root/~nobody/g' test/helper-expand.c
  # '';

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [
    libxkbcommon
    pango
    cairo
    git
    bison
    flex
    librsvg
    check
    libstartup_notification
    libxcb
    xcbutil
    xcbutilwm
    xcbutilxrm
    xcb-util-cursor
    which
  ];

  doCheck = false;

  # meta = with lib; {
  #   description = "Window switcher, run dialog and dmenu replacement";
  #   homepage = "https://github.com/davatorium/rofi";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ bew ];
  #   platforms = with platforms; linux;
  # };
}




