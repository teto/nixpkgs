{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "docling-serve-ui";
  version = "1.38.2";

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling-serve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B71HuMIUQG+tSogW1pPlMtcBtZQ8kkWppKNdZDFwgEM=";
  };

  npmRoot = "ui";
  npmDepsHash = "sha256-lEKhwvkVMGuMVjk87/u19ridN/dQnFRh+I9G6s4eMBQ=";

  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild
    mkdir -p docling_serve/ui_static
    npm --prefix ui run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/docling-serve-ui
    cp -r docling_serve/ui_static/. $out/share/docling-serve-ui/
    runHook postInstall
  '';

  meta = {
    description = "Web UI for Docling Serve";
    homepage = "https://github.com/docling-project/docling-serve";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
