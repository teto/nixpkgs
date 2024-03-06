{ lua
, hello
, wrapLua
, pkgs
}:
let
  runTest = lua: { name, command }:
    pkgs.runCommandLocal "test-${lua.name}-${name}" ({
      nativeBuildInputs = [lua];
      meta.platforms = lua.meta.platforms;
    }) (''
      source ${./assert.sh}
    ''
    + command
    + "touch $out"
    );

  wrappedHello = hello.overrideAttrs(oa: {
    propagatedBuildInputs = [
      wrapLua
      lua.pkgs.cjson
    ];
    postFixup = ''
      wrapLuaPrograms
    '';
  });

  luaWithModule = lua.withPackages(ps: [
    ps.lua-cjson
  ]);

  golden_LUA_PATHS = {

    "5.1" = "./?.lua;${lua}/share/lua/5.1/?.lua;${lua}/share/lua/5.1/?/init.lua;${lua}/lib/lua/5.1/?.lua;${lua}/lib/lua/5.1/?/init.lua";
    "5.2" = "${lua}/share/lua/5.2/?.lua;${lua}/share/lua/5.2/?/init.lua;${lua}/lib/lua/5.2/?.lua;${lua}/lib/lua/5.2/?/init.lua;./?.lua";
    "5.3" = "${lua}/share/lua/5.3/?.lua;${lua}/share/lua/5.3/?/init.lua;${lua}/lib/lua/5.3/?.lua;${lua}/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua";
    "5.4" = "${lua}/share/lua/5.4/?.lua;${lua}/share/lua/5.4/?/init.lua;${lua}/lib/lua/5.4/?.lua;${lua}/lib/lua/5.4/?/init.lua;./?.lua;./?/init.lua";
  };
in
  pkgs.recurseIntoAttrs ({

  checkInterpreterPatch = let
    golden_LUA_PATH = golden_LUA_PATHS.${lua.luaversion};
  in
    runTest lua {
    name = "check-default-lua-path";
    command = ''
      generated=$(lua -e 'print(package.path)')
      echo "lua: ${lua}"
      echo "${golden_LUA_PATH}"
      assertStringEqual "$generated" "${golden_LUA_PATH}"
      export LUA_PATH=";;"
      assertStringEqual "$generated" "${golden_LUA_PATH}"
      '';
  };

  checkWrapping = pkgs.runCommandLocal "test-${lua.name}-wrapping" ({
    }) (''
      grep -- 'LUA_PATH=' ${wrappedHello}/bin/hello
      touch $out
    '');

  checkRelativeImports = pkgs.runCommandLocal "test-${lua.name}-relative-imports" ({
    }) (''
      source ${./assert.sh}

      lua_vanilla_package_path="$(${lua}/bin/lua -e "print(package.path)")"
      lua_with_module_package_path="$(${luaWithModule}/bin/lua -e "print(package.path)")"

      assertStringContains "$lua_vanilla_package_path" "./?.lua"
      assertStringContains "$lua_vanilla_package_path" "./?/init.lua"

      assertStringContains "$lua_with_module_package_path" "./?.lua"
      assertStringContains "$lua_with_module_package_path" "./?/init.lua"

      touch $out
    '');
})
