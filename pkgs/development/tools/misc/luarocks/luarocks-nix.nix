{ luarocks, fetchFromGitHub, unstableGitUpdater }:
luarocks.overrideAttrs(old: {
  pname = "luarocks-nix";
  version = "unstable-2022-06-24";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "luarocks-nix";
    rev = "115be066b12e1a4be82f2b26f1df5760afc21080";
    sha256 = "sha256-FpkDWlDHPdeug4ajl3D7g61H9jfT6sPwAhjGtYdX0kw=";
  };
  patches = [];

  passthru = {
    updateScript = unstableGitUpdater {};
  };

  meta.mainProgram = "luarocks";
})
