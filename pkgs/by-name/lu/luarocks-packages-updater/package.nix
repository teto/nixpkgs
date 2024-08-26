{ nix
, makeWrapper
, python3Packages
, lib
, nix-prefetch-scripts
, luarocks-nix
, lua5_1
, lua5_2
, lua5_3
, lua5_4
, pluginupdate
}:
let

  path = lib.makeBinPath [
    nix nix-prefetch-scripts luarocks-nix
  ];

  attrs = builtins.fromTOML (builtins.readFile ./pyproject.toml);
  pname = attrs.project.name;
  inherit (attrs.project) version;
in

python3Packages.buildPythonApplication {
  inherit pname version;
  pyproject = true;

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    makeWrapper
    python3Packages.setuptools
    # python3Packages.wrapPython
  ];

  propagatedBuildInputs = [
    python3Packages.gitpython
  ];

  # installPhase =
  #   ''
  #   # wrap python scripts
  #   makeWrapperArgs+=( --prefix PATH : "${path}" --prefix PYTHONPATH : "$out/lib" \
  #     --set LUA_51 ${lua5_1} \
  #     --set LUA_52 ${lua5_2} \
  #     --set LUA_53 ${lua5_3} \
  #     --set LUA_54 ${lua5_4}
  #   )
  #   wrapPythonProgramsIn "$out"
  # '';

  # TODO add to PYTHONPATH pluginupdate
  # --prefix PYTHONPATH : "
  postFixup = ''
    echo "pluginupdate folder ${pluginupdate}"
    wrapProgram $out/bin/luarocks-packages-updater \
     --prefix PYTHONPATH : "${pluginupdate}" \
     --prefix PATH : "${path}"
  '';
      # --add-flags "--patterns ${allowedPatternsPath}" \

  shellHook = ''
    export PYTHONPATH="maintainers/scripts/pluginupdate-py:$PYTHONPATH"
    export PATH="${path}:$PATH"
  '';

  meta = {
    inherit (attrs.project) description;
    license = lib.licenses.gpl3Only;
    homepage = attrs.project.urls.Homepage;
    mainProgram = "luarocks-packages-updater";
    maintainers = with lib.maintainers; [ teto ];
  };
}


