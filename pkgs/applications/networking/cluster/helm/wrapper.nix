{ stdenv, symlinkJoin, lib, makeWrapper
, writeText
, runCommandNoCC
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
    version = stdenv.lib.getVersion helm;
    initialMakeWrapperArgs = [
      "${helm}/bin/helm" "${placeholder "out"}/bin/helm"
      "--argv0" "$0"
      "--set" "HELM_PLUGINS" "${pluginsDir}"
      # "--set" "HELM_CONFIG_HOME" confDir
    ];

    pluginsDir = concatStringsSep ":" plugins;

    # TODO this tries to connect via internet :s
    confDir = runCommandNoCC "helm-config-${version}" {
      HELM_CONFIG_HOME = "$out";
    } ''
      ${helm}/bin/helm repo add elastic https://helm.elastic.co
    '';

  in
  symlinkJoin {
    name = "helm-${version}";

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
