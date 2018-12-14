{ nixpkgs ? import ../.. { }
}:
with nixpkgs;
let
  pyEnv = python3.withPackages(ps: [
    ps.GitPython
    ps.pyyaml
  ]);
in
mkShell {
  packages = [
    nodePackages.node2nix
    pyEnv
    nix-prefetch-scripts
  ];
}

