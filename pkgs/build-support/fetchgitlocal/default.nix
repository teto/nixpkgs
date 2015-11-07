{ runCommand, git, nix }: src:

let
  srcStr = toString src;

  # Adds the current directory in the index (respecting ignored files) to the git store,
  # and returns the hash
  gitHashFile = runCommand "put-in-git" {
      nativeBuildInputs = [ git ];
      dummy = builtins.currentTime; # impure, do every time
      preferLocalBuild = true;
    } ''
      # `tr` to remove trailing newline
      git -C ${srcStr} write-tree | tr -d '\n' > $out
    '';

  gitHash = builtins.readFile gitHashFile; # cache against git hash

  nixPath = runCommand "put-in-nix" {
      nativeBuildInputs = [ git ];
      preferLocalBuild = true;
    } ''
      mkdir $out

      # dump tar of *current directory* at given revision
      git -C ${srcStr} archive --format=tar ${gitHash} \
        | tar xf - -C $out
    '';

in nixPath
