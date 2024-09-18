{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
let
  pname = "ente-cli";
  version = "0.2.1";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "ente-io";
    repo = "ente";
    rev = "refs/tags/cli-v${version}";
    hash = "sha256-gIDJUj2pn8rndXWN69bZdVfRLVB7AybXHMcioG2NI1k=";
    fetchSubmodules = false;
    sparseCheckout = [ "cli" ];
  };

  modRoot = "./cli";

  vendorHash = "sha256-Gg1mifMVt6Ma8yQ/t0R5nf6NXbzLZBpuZrYsW48p0mw=";

  CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.AppVersion=cli-v${version}"
  ];

  postInstall = ''
    mv $out/bin/{cli,ente-cli}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "cli-(.+)"
    ];
  };

  meta = {
    description = "CLI client for downloading your data from Ente";
    longDescription = ''
      The Ente CLI is a Command Line Utility for exporting data from Ente. It also does a few more things, for example, you can use it to decrypting the export from Ente Auth.
    '';
    homepage = "https://github.com/ente-io/ente/tree/main/cli#readme";
    changelog = "https://github.com/ente-io/ente/releases/tag/cli-v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.zi3m5f ];
    platforms = [
      "aarch64-linux"
      "armv7a-linux"
      "i686-linux"
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "i686-windows"
      "x86_64-windows"
    ];
    mainProgram = pname;
  };
}
