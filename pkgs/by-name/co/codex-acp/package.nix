{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  libcap,
  bubblewrap,
  librusty_v8 ? callPackage ./librusty_v8.nix { },
}:
let
  # codex-acp 0.15.0 pins openai/codex rust-v0.133.0 in Cargo.lock.
  codexRev = "9474e5cfc4494b0ba319352aa86ce436c59e65c8";
  codexHash = "sha256-RTxhhZjZ/64N60pmbNVzLwcSBomn67pPDpOjkL6RPUw=";
  codexSrc = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    rev = codexRev;
    hash = codexHash;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "codex-acp";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "codex-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XSy0qJudzt5ZN9TWQsWhKvfKkPBPAH7vF1RV96P268w=";
  };

  cargoHash = "sha256-p1gC5PhulWnAAp/jZpl4Kh1d5ZexAdyB/YPjU5/Ap04=";

  # fetchCargoVendor only keeps the individual git crate subtrees. Older Codex
  # crates included this workspace-root file from codex-core.
  postPatch = ''
    if [ -e ${codexSrc}/codex-rs/node-version.txt ]; then
      cp ${codexSrc}/codex-rs/node-version.txt "$cargoDepsCopy/source-git-0/node-version.txt"
    fi
  '';

  env = {
    RUSTY_V8_ARCHIVE = librusty_v8;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isLinux {
    CODEX_BWRAP_SOURCE_DIR = "${bubblewrap.src}";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
  ];

  doCheck = false;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "An ACP-compatible coding agent powered by Codex";
    homepage = "https://github.com/zed-industries/codex-acp";
    changelog = "https://github.com/zed-industries/codex-acp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "codex-acp";
  };
})
