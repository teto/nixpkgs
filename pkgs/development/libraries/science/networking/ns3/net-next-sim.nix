{
  stdenv
  , fetchFromGithub
}:

stdenv.mkDerivation {

  pname = "libos";
  src = fetchFromGithub {
    url = https://github.com/libos-nuse/net-next-nuse;
    owner = "libos-nuse";
    repo = "net-next-nuse";
    rev = "25a9dd363ccf75cc3c58756049c4864d9bc88f9b";
    sha256 = "0f3g47mql8jjzn2q6lm0cbb5fv62sdqafdvx5g8s3lqri1sca14n";

  };
}
