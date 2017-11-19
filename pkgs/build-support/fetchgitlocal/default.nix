{ runCommand, git, nix }: src:

let
  tmpFolder =  "/tmp/fetchgitlocal-${builtins.toString currentTime}";
  currentTime = builtins.currentTime; # impure, do every time

  srcStr = toString src;

  # Adds the current directory in the index (respecting ignored files) to the git store,
  # and returns the hash
  gitHashFile = runCommand "put-in-git" {
      nativeBuildInputs = [ git ];
      dummy = currentTime;
      preferLocalBuild = true;
    } ''
      # cd ${srcStr}
      set -x sh
      echo CWD=$PWD

      # `tr` to remove trailing newline
      cp -r ${srcStr}/.git ${tmpFolder}
      chmod a+w ${tmpFolder}
      export GIT_DIR=${tmpFolder}

      # > $out
      echo OUT=$out
      echo USER=$USER
      res="$(git rev-parse --show-prefix)"
      git write-tree --prefix="$res" | tr -d '\n' >  $out
    '';

  gitHash = builtins.readFile gitHashFile; # cache against git hash

  nixPath = runCommand "put-in-nix" {
      nativeBuildInputs = [ git ];
      preferLocalBuild = true;
    } ''
      set -x
      mkdir $out

      # git annoyingly breaks without doing this since the hash does
      # not correspond to repo root.
      # -C => as if git was run from tthat place
      # show-top-level => sjow fullpath
      cd $(git -C ${srcStr} rev-parse --show-toplevel)

      # dump tar of *current directory* at given revision
      hash="${gitHash}"
      git archive --format=tar $hash \
        | tar xv - -C $out
    '';

in nixPath
