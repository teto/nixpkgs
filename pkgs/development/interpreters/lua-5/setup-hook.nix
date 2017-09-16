{ runCommand }:

# sitePackages:

let
  hook = ./setup-hook.sh;
in runCommand "lua-setup-hook.sh" {
  # hum TODO
  # inherit libFolder;

} ''
  cp ${hook} hook.sh
  substituteAllInPlace hook.sh
  mv hook.sh $out
''
