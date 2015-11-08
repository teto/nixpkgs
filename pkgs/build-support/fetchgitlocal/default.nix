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
      cd ${srcStr}

      # `tr` to remove trailing newline
      git write-tree --prefix=$(git rev-parse --show-prefix) | tr -d '\n' > $out
    '';

  gitHash = builtins.readFile gitHashFile; # cache against git hash

  nixPath = runCommand "put-in-nix" {
      nativeBuildInputs = [ git ];
      preferLocalBuild = true;
    } ''
      mkdir $out

      # git annoyingly breaks without doing this since the hash does
      # not correspond to repo root.
      cd $(git -C ${srcStr} rev-parse --show-toplevel)

      # dump tar of *current directory* at given revision
      git archive --format=tar ${gitHash} \
        | tar xv - -C $out
    '';

in nixPath
