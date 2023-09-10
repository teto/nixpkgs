{ pkgs ? import ../../../../.. { } }:

# Ideally, pkgs points to default.nix file of Nixpkgs official tree
with pkgs;
let
  pyEnv = python3.withPackages (ps: [
    ps.gitpython
    ps.py-tree-sitter
  ]);
in

mkShell {
  packages = [
    bash
    pyEnv
    nix
    nix-prefetch-scripts
  ];

  NIX_GRAMMAR = tree-sitter-grammars.tree-sitter-nix;
}
