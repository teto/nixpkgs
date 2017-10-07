{ buildEnv, luaPackages }:

# f: let packages = f pythonPackages; in buildEnv.override { extraLibs = packages; }
# this is a function that returns a function that returns an environment
# withPackage ([]) so f must accept some list ?
f: let packages = f luaPackages; in buildEnv.override { extraLibs = packages; }
