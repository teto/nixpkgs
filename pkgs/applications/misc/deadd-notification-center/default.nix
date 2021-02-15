{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, wrapGAppsHook
, hicolor-icon-theme
, gtk3
, gobject-introspection
, libxml2
}:
stdenv.mkDerivation rec {
  pname = "deadd-notification-center";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "phuhl";
    repo = "linux_notification_center";
    rev = version;
    sha256 = "QaOLrtlhQyhMOirk6JO1yMGRrgycHmF9FAdKNbN2TRk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    gobject-introspection
    libxml2
    hicolor-icon-theme
  ];

  buildFlags = [
    # Exclude stack from `make all` to use the prebuilt binary from .out/
    "service"
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "SERVICEDIR_SYSTEMD=${placeholder "out"}/etc/systemd/user"
    "SERVICEDIR_DBUS=${placeholder "out"}/share/dbus-1/services"
    # Override systemd auto-detection.
    "SYSTEMD=1"
  ];

  meta = with lib; {
    description = "A haskell-written notification center for users that like a desktop with style";
    homepage = "https://github.com/phuhl/linux_notification_center";
    license = licenses.bsd3;
    maintainers = [ maintainers.pacman99 ];
    platforms = platforms.linux;
  };
}
