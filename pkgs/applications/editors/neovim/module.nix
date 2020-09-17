{ lib, config, vimUtils, haskellPackages, pythonPackages, python3Packages,
nodePackages, bundlerEnv, ruby, ... }:

with lib;
let
  /* for compatibility with passing extraPythonPackages as a list; added 2018-07-11 */
  compatFun = funOrList: (if builtins.isList funOrList then
    (_: lib.warn "passing a list as extraPythonPackages to the neovim wrapper is deprecated, pass a function as to python.withPackages instead" funOrList)
    else funOrList);

#  type = with types; attrsOf (submodule (
#    { name, config, ... }:
#    { options = {
#
#        enable = mkOption {
#          type = types.bool;
#          default = true;
#          description = ''
#            Whether this /etc file should be generated.  This
#            option allows specific /etc files to be disabled.
#          '';
#        };
#
#        target = mkOption {
#          type = types.str;
#          description = ''
#            Name of symlink (relative to
#            <filename>/etc</filename>).  Defaults to the attribute
#            name.
#          '';
#        };
#
#        text = mkOption {
#          default = null;
#          type = types.nullOr types.lines;
#          description = "Text of the file.";
#        };
#
#        source = mkOption {
#          type = types.path;
#          description = "Path of the source file.";
#        };
#
#        # mode = mkOption {
#        #   type = types.str;
#        #   default = "symlink";
#        #   example = "0600";
#        #   description = ''
#        #     If set to something else than <literal>symlink</literal>,
#        #     the file is copied instead of symlinked, with the given
#        #     file mode.
#        #   '';
#        # };
#
#        # uid = mkOption {
#        #   default = 0;
#        #   type = types.int;
#        #   description = ''
#        #     UID of created file. Only takes effect when the file is
#        #     copied (that is, the mode is not 'symlink').
#        #     '';
#        # };
#
#        # gid = mkOption {
#        #   default = 0;
#        #   type = types.int;
#        #   description = ''
#        #     GID of created file. Only takes effect when the file is
#        #     copied (that is, the mode is not 'symlink').
#        #   '';
#        # };
#
#        # user = mkOption {
#        #   default = "+${toString config.uid}";
#        #   type = types.str;
#        #   description = ''
#        #     User name of created file.
#        #     Only takes effect when the file is copied (that is, the mode is not 'symlink').
#        #     Changing this option takes precedence over <literal>uid</literal>.
#        #   '';
#        # };
#
#        # group = mkOption {
#        #   default = "+${toString config.gid}";
#        #   type = types.str;
#        #   description = ''
#        #     Group name of created file.
#        #     Only takes effect when the file is copied (that is, the mode is not 'symlink').
#        #     Changing this option takes precedence over <literal>gid</literal>.
#        #   '';
#        # };
#
#      };

  buildHaskellEnv = locs: defs:
    haskellPackages.ghcWithPackages(hs:
    # builtins.trace "haskellPackages"
      [
        # hs.nvim-hs
        # hs.hies-all.
        # hs.all-hies.versions.ghc865
        # ps.nvim-hs-ghcid # broken jailBreak ?
      ]
      ++ (config.extraHaskellPackages hs)
      );
      # TODO use shellFor instead
      # haskellPackage.shellFor {
      #   packages = drvs;
      #   withHoogle = true;
      #   # haskellPackages.stack
      #   nativeBuildInputs = [

      #     haskellPackages.hie  # defined from my overlay
      #     haskellPackages.cabal-install
      #     # haskellPackages.bytestring-conversion
      #     haskellPackages.gutenhasktags
      #     haskellPackages.haskdogs # seems to build on hasktags/ recursively import things
      #     haskellPackages.hasktags
      #     haskellPackages.nvim-hs
      #     # haskellPackages.nvim-hs-ghcid # broken

      #     # for https://hackage.haskell.org/package/bytestring-conversion-0.2/candidate/docs/Data-ByteString-Conversion-From.html
      #   ]
        # ++ extraHaskellPackages
        # ;
      # };

  buildRubyEnv = locs: defs:
    bundlerEnv {
      name = "neovim-ruby-env";
      gemdir = ./ruby_provider;
      postBuild = ''
        ln -sf ${ruby}/bin/* $out/bin
      '';
    };

  # TODO must accept a tree to symlink
  # buildEnv with

  # TODO each vimPlugin should contain the name where to write after
  # TODO use later
  vimPlugin = types.submodule {
    # enum
    options = {
      loadingType = mkOption {
        default = null;
        # lines
        type = types.nullOr types.str;
        description = ''
          Vimscript to load afterwards
        '';
      };

      afterRC = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          Vimscript to load afterwards
        '';
      };

      optional = mkOption {
        default = false;
        type = types.boolean;
        description = ''
          Vimscript to load afterwards
        '';
      };

      customRC = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          To be appended only if this plugin is loaded
        '';
      };
    };
  };


  # TODO
  vimRC = vimUtils.vimrcContent (config.configure
  // {
    # inherit (config)
    customRC = config.customRC or "";
  }
  );

  buildPython3Env = let
      pluginPython3Packages = getDeps "python3Dependencies" (requiredPlugins config);
    in
      locs: defs:
      python3Packages.python.withPackages (ps:
              [ ps.pynvim ]
              ++ (config.extraPython3Packages ps)
              ++ (concatMap (f: f ps) pluginPython3Packages)
              );

    createPythonEnv = let
      pluginPythonPackages = getDeps "pythonDependencies" (requiredPlugins config);
    in
      locs: defs:
        pythonPackages.python.withPackages(ps:
          [ ps.pynvim ]
          ++ (config.extraPythonPackages ps)
          ++ (concatMap (f: f ps) pluginPythonPackages)
          );


  generatedNeovimRC = locs: defs:
        (concatStringsSep "\n" (getValues defs)) +
    ''
      ${if config.withNodeJs then "let g:node_host_prog='${nodePackages.neovim}/bin/neovim-node-host'" else "let g:loaded_node_provider=1"}
      ${if config.withPython then "let g:python_host_prog='${config.pythonEnv}/bin/python'" else "let g:loaded_python_provider=1"}
      ${if config.withPython3 then "let g:python3_host_prog='${config.python3Env}/bin/python'" else "let g:loaded_python3_provider=1"}
      ${if config.withRuby then "let g:ruby_host_prog='${config.rubyEnv}/bin/ruby'" else "let g:loaded_ruby_provider=1"}
      ${if config.withHaskell then "let g:haskell_host_prog='${config.haskellEnv}/bin/ghc'" else "let g:loaded_haskell_provider=1"}
    ''
    + optionalString config.withHaskell ''
      " start haskell host if required  {{{
      if has('nvim')
        function! s:RequireHaskellHost(name)
            return jobstart([ '${config.haskellEnv}/bin/nvim-hs', a:name.name], {'rpc': v:true, 'cwd': stdpath('config') })
        endfunction
      call remote#host#Register('haskell', "*.l\?hs", function('s:RequireHaskellHost'))
      endif
    "}}}
    ''
    + vimRC
    ;

  addToPath = mkOptionType {
    name = "addToPath";
    description = "packages to wrap";
    check = types.list;
    default = [];
  };

  extraPythonPackageType = mkOptionType {
    name = "extra-python-packages";
    description = "python packages in python.withPackages format";
    check = with types; (x: if isFunction x
      then isList (x pkgs.pythonPackages)
      else false);
    merge = mergeOneOption;
  };

  extraPython3PackageType = mkOptionType {
    name = "extra-python3-packages";
    description = "python3 packages in python.withPackages format";
    check = with types; (x: if isFunction x
      then isList (x pkgs.python3Packages)
      else true);
    # merge = mergeOneOption;
    # this should work ??? why
    # merge = mergeDefaultOption;

    # needs to retun a new function that calls the over function
    merge = loc: defs:
      # returns a function that passes the arg to a list
      x:
        foldr (a: b: a ++ b) []
        (map (f: f x) (getValues defs))
        ;
      # x: foldr (a: b:
      #   r: ( debug.traceVal(a) r) ++ ( debug.traceVal(b) r ))  # op
      #   (_: []) # nul
      #   (debug.traceValFn (x: "print values: ") (getValues defs));
      # x: foldr (a: b: ( debug.traceVal(a x)) ++ ( debug.traceVal ( b x ))) lib.id (getValues defs);
  };

  # original is
  # requiredPlugins = vimUtils.requiredPlugins configure;
  requiredPlugins = config: vimUtils.requiredPlugins (config.configure // {
    inherit (config) customRC;
  })
  ;

  getDeps = attrname: map (plugin: plugin.${attrname} or (_:[]));

in
{

  options = {

    viAlias = mkOption {
      type = types.bool;
      default = false;
      description = "Symlink `vi` to `nvim` binary.";
    };

    vimAlias = mkOption {
      type = types.bool;
      default = false;
      description = "Symlink `vim` to `nvim` binary.";
    };

    /*
      Kind of experimental
     */
    dependencies = mkOption {
      type = types.listOf types.package;
      default = false;
      description = ''
        (Experimental) list all dependencies, the module will create the appropriate
        environments for them.
      '';
    };

    # kept to make the transition smoother
    # TODO
    # should be translated up
    configure = mkOption {
      type = types.attrs;
      default = {};
      example = literalExample ''
        configure = {
            customRC = $''''
            " here your custom configuration goes!
            $'''';
            packages.myVimPackage = with pkgs.vimPlugins; {
              # loaded on launch
              start = [ fugitive ];
              # manually loadable by calling `:packadd $plugin-name`
              opt = [ ];
            };
          };
      '';
      description = ''
        Legacy way of configuring (neo)vim. Still used for plugin manager specific configuration.
        See <link xlink:href='https://nixos.wiki/wiki/Vim'>the wiki</link>.
      '';
    };

    withNodeJs = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable node provider. Set to <literal>true</literal> to
        use Node plugins.
      '';
    };

    withHaskell = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable haskell provider nvim-hs. Set to <literal>true</literal> to
        use haskell plugins.
      '';
    };

    withPython = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable Python 2 provider. Set to <literal>true</literal> to
        use Python 2 plugins.
      '';
    };

    haskellEnv = mkOption {
      type = types.nullOr types.unspecified // { merge = buildHaskellEnv; };
      default = null;
      description = ''
        Haskell environment.
      '';
    };

    rubyEnv = mkOption {
      type = types.nullOr types.package // { merge = buildRubyEnv; };
      default = null;
      description = ''
        Ruby environment.
      '';
    };

    python3Env = mkOption {
      type = types.nullOr types.package // { merge = buildPython3Env; };
      default = null;
      description = ''
        Read only Python 3 environment.
      '';
    };

    pythonEnv = mkOption {
      type = types.nullOr types.package // { merge = createPythonEnv; };
      default = null;
      description = ''
        Python 2 environment.
      '';
    };

    extraPythonPackages = mkOption {
      type = with types; either extraPythonPackageType (listOf package);
      default = (_: []);
      defaultText = "ps: []";
      example = literalExample "(ps: with ps; [ pandas jedi ])";
      description = ''
        A function in python.withPackages format, which returns a
        list of Python 2 packages required for your plugins to work.
      '';
    };

    withRuby = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable ruby provider.
      '';
    };

    # vimRC = mkOption {
    #   # readOnly = true;
    #   type = types.lines;
    #   default = "";
    #   description = ''
    #     The content of the vimrc generated from the other parameters.
    #   '';
    # };

    # alias it to init.file
    neovimRC = mkOption {
      # readOnly = true;
      # check = x: true;
      # why is it called twice ?
      type = types.lines // { merge = generatedNeovimRC; };
      default = "";
      description = ''
        The content of the init.vim generated from the other parameters.
      '';
    };

    withPython3 = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable Python 3 provider. Set to <literal>true</literal> to
        use Python 3 plugins.
      '';
    };

    extraHaskellPackages = mkOption {
      # type = with types; extraPython3PackageType;
      default = (_: []);
      defaultText = "ps: []";
      apply = compatFun;
      example = literalExample "(ps: with ps; [ python-language-server ])";
      description = ''
        A function in python.withPackages format, which returns a
        list of Python 3 packages required for your plugins to work.
      '';
    };

    # TODO
    pluginsExperimental = mkOption {
      type = types.attrsOf vimPlugin;
      example = literalExample ''
        [
          vim-fugitive
          vim-grepper
        ]
      }'';
      default = [];
      description = ''
        Plugins to load on start.
      '';
    };

    plugins = mkOption {
      type = types.listOf types.package;
      example = literalExample ''
        with vimPlugins; [
          vim-fugitive
          vim-grepper
        ]
      }'';
      default = [];
      description = ''
        Plugins to load on start.
      '';
    };

    # optionalPlugins = mkOption {
    #   type = types.attrsOf vimPlugin;
    #   example = literalExample ''
    #     [ phpCompletion elm-vim ]
    #   }'';
    #   # default = [];
    #   default = configure.optionalPlugins or [];
    #   description = ''
    #     Plugins made manually loadable through :packadd <plugin>
    #   '';
    # };

    extraPython3Packages = mkOption {
      type = with types; extraPython3PackageType;
      default = (_: []);
      defaultText = "ps: []";
      apply = compatFun;
      example = literalExample "(ps: with ps; [ python-language-server ])";
      description = ''
        A function in python.withPackages format, which returns a
        list of Python 3 packages required for your plugins to work.
      '';
    };

    customRC = mkOption {
      type = types.lines;
      example = literalExample ''
        set hidden
      }'';
      default = "";
      description = ''
        Structured kernel configuration.
      '';
    };
  };

  config = {
    # optional
    # python3Env = let
    #   pluginPython3Packages = getDeps "python3Dependencies" (requiredPlugins config);
    # in
    #   python3Packages.python.withPackages (ps:
    #           [ ps.pynvim ]
    #           ++ (config.extraPython3Packages ps)
    #           # ++ debug.traceVal (config.extraPython3Packages ps)
    #           ++ (concatMap (f: f ps) pluginPython3Packages)
    #           );

    # haskellEnv = haskellPackages.ghcWithPackages(ps: [ ps.nvim-hs ps.nvim-hs-ghcid]);


    # config.configure.packages.myVimPackage.start
    # infinite loop
    configure.packages.myVimPackage.start =  config.plugins;
    # neovimRC = generatedNeovimRC;

  };
}

