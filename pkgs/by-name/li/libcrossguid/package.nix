{
  lib,
  stdenv,
  fetchFromGitHub,
  libuuid,
  cmake
}:

stdenv.mkDerivation (finalAttrs: {
  name = "lib" + "crossguid" + "-" + finalAttrs.version;
  pname = "crossguid";
  version = "2019-05-29";

  src = fetchFromGitHub {
    owner = "graeme-hill";
    repo = "crossguid";
    rev = "8f399e8bd4252be9952f3dfa8199924cc8487ca4";
    sha256 = "1i29y207qqddvaxbn39pk2fbh3gx8zvdprfp35wasj9rw2wjk3s9";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libuuid ];

  meta = with lib; {
    description = "Lightweight cross platform C++ GUID/UUID library";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ edwtjo ];
    homepage = "https://github.com/graeme-hill/crossguid";
    platforms = with lib.platforms; linux;
  };

})
