{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  SDL2,
  libGLU,
  libGL,
  openal,
  luajit,
  libdevil,
  freetype,
  physfs,
  libmodplug,
  mpg123,
  libvorbis,
  libogg,
  libtheora,
  which,
  autoconf,
  automake,
  libtool,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "love";
  version = "11.5";

  src = fetchFromGitHub {
    owner = "love2d";
    repo = "love";
    rev = version;
    sha256 = "sha256-wZktNh4UB3QH2wAIIlnYUlNoXbjEDwUmPnT4vesZNm0=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];
  buildInputs = [
    SDL2
    xorg.libX11 # SDl2 optional depend, for SDL_syswm.h
    libGLU
    libGL
    openal
    luajit
    libdevil
    freetype
    physfs
    libmodplug
    mpg123
    libvorbis
    libogg
    libtheora
    which
    libtool
  ];

  preConfigure = "$shell ./platform/unix/automagic";

  configureFlags = [
    "--with-lua=luajit"
  ];

  env.NIX_CFLAGS_COMPILE = "-DluaL_reg=luaL_Reg"; # needed since luajit-2.1.0-beta3

  meta = {
    homepage = "https://love2d.org";
    description = "Lua-based 2D game engine/scripting language";
    mainProgram = "love";
    license = lib.licenses.zlib;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.raskin ];
  };
}
