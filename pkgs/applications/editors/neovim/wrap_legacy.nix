{ wrapNeovim2, makeNeovimConfig }:

neovim:
let
  wrapper = {
      extraMakeWrapperArgs ? ""
    , withPython ? false,  extraPythonPackages ? (_: []) /* the function you would have passed to python.withPackages */
    , withPython3 ? true,  extraPython3Packages ? (_: []) /* the function you would have passed to python.withPackages */
    , withNodeJs ? false
    , withRuby ? true
    # TODO these should disappear really
    , vimAlias ? false
    , viAlias ? false
    , configure ? {}
  } @ cfg:
    let
      res = makeNeovimConfig {
        inherit withPython extraPythonPackages;
        inherit withPython3 extraPython3Packages;
        inherit withNodeJs withRuby;

        inherit configure;
      };

    in
      wrapNeovim2 neovim res;
in
  wrapper

