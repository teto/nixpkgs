{ buildEnv, luaPackages }:

# f: let packages = f pythonPackages; in buildEnv.override { extraLibs = packages; }
f: let packages = f luaPackages; in buildEnv.override { extraLibs = packages; }
