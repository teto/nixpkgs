{ stdenv, symlinkJoin, lib, makeWrapper
, writeText
}:
with stdenv.lib;

helm:

let
  wrapper = {
    plugins ? [],
    repositories ? {}, # name = ... / url = ...
    extraMakeWrapperArgs ? ""
  }:
  let

    initialMakeWrapperArgs = [
      "${helm}/bin/helm" "${placeholder "out"}/bin/helm"
      "--argv0" "$0"
      "--set" "HELM_PLUGINS" "${pluginsDir}"
      "--set" "HELM_CONFIG_HOME" confDir
    ];

    pluginsDir = concatStringsSep ":" plugins;

    # TODO run helm add repo
    confDir = "";

  in
  symlinkJoin {
    name = "helm-${stdenv.lib.getVersion helm}";

    # Remove the symlinks created by symlinkJoin which we need to perform
    # extra actions upon
    postBuild = ''
      rm $out/bin/helm
      makeWrapper ${lib.escapeShellArgs initialMakeWrapperArgs}  ${extraMakeWrapperArgs}
    '';
    paths = [ helm ];

    preferLocalBuild = true;

    nativeBuildInputs = [ makeWrapper ];
    passthru = { unwrapped = helm; };

    meta = helm.meta // {
      # To prevent builds on hydra
      hydraPlatforms = [];
      # prefer wrapper over the package
      priority = (helm.meta.priority or 0) - 1;
    };
  };
in
  lib.makeOverridable wrapper
