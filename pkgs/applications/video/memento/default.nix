{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  wrapQtAppsHook,

  # before that => zeal
  sqlite,
  json_c,
  mecab,
  libzip,
  mpv,
  yt-dlp,
  # optional
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "memento";
  version = "1.6.0";

  # src = fetchFromGitHub {
  #   owner = "ripose-jp";
  #   repo = "Memento";
  #   rev = "v${finalAttrs.version}";
  #   hash = "sha256-IvzvlToSyA20FWU0x+wgE3rT0dYbuY6xyaGgz1D1f6Q=";
  # };


  # testing https://github.com/ripose-jp/Memento/discussions/302#discussioncomment-14985736
  src = fetchFromGitHub {
    owner = "teto";
    repo = "Memento";
    rev = "50950c8ffa2b62fb8fd3089a1ed2427b4d894552";
    # hash = "sha256-IvzvlToSyA20FWU0x+wgE3rT0dYbuY5xyaGgz1D1f6Q=";
    hash = "sha256-/wyITKR2QE7DJMeMcbYrpsuxIOM0r4s6vNxyd1cQI3Q=";
  };

  cmakeFlags = [
    # (lib.cmakeBool "MECAB_SUPPORT" true)
    "-Dmocr_DIR=${libmocr}"
  ]
  ++ lib.optional withOcr (lib.cmakeBool "OCR_SUPPORT" true);

  nativeBuildInputs = [
    cmake
    makeWrapper
    wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    sqlite
    json_c
    libzip
  ]
  ++ lib.optionals withOcr [ libmocr python3.pkgs.manga-ocr ]
  ;

  propagatedBuildInputs = [ mpv ];

  preFixup = ''
    wrapProgram "$out/bin/memento" \
      --prefix PATH : "${yt-dlp}/bin" \
  '';

  meta = with lib; {
    description = "Mpv-based video player for studying Japanese";
    homepage = "https://ripose-jp.github.io/Memento/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ teto ];
    platforms = platforms.linux;
    mainProgram = "memento";
  };
})
