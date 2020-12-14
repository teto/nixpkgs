{ stdenv, fetchFromGitHub, fetchurl, fetchzip }:
{

  helm-s3 = let
    version = "0.10.0";
  in fetchzip {
      url = "https://github.com/hypnoglow/helm-s3/releases/download/v${version}/helm-s3_${version}_linux_amd64.tar.gz";
      sha256 = "sha256-sCtDBo/1XE+oF+qwtWlZ4dI5LgQIp8RjLYhzQ5Hl9KY=";
      stripRoot = false;
      extraPostFetch = ''
        set -x
        echo $out
        mkdir $out/plugin
        GLOBIGNORE="$out/plugin"
        mv $out/* $out/plugin
      '';
  };

}
