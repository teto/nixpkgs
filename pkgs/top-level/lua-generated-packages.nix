/* ${GENERATED_NIXFILE} is an auto-generated file -- DO NOT EDIT! */
{ self, stdenv
, fetchurl
, toLuaModule
, requiredLuaModules
}:
with self;
rec {
mediator_lua = buildLuaPackage rec {
meta={
homepage="http://olivinelabs.com/mediator_lua/";
license=stdenv.lib.licenses.mit;
description="Event handling through channels"; }
;
src= fetchurl {
url="http://luarocks.org/manifests/teto/mediator_lua-1.1.2-0.src.rock";
sha256="18j49vvs94yfk4fw0xsq4v3j4difr6c99gfba0kxairmcqamd1if"; }
;
propagatedBuildInputs=[ lua];
version="1.1.2-0";
name="mediator_lua"; }
;

luasystem = buildLuaPackage rec {
src= fetchurl {
url=https://luarocks.org/luasystem-0.2.1-0.src.rock;
sha256="091xmp8cijgj0yzfsjrn7vljwznjnjn278ay7z9pjwpwiva0diyi"; }
;
pname="luasystem";
version="0.2.1-0";
meta={
description="Platform independent system calls for Lua.";
license=stdenv.lib.licenses.mit;
homepage=http://olivinelabs.com/luasystem/; }
;
propagatedBuildInputs=[ lua]; }
;

mpack = buildLuaPackage rec {
pname="mpack";
meta={
license=stdenv.lib.licenses.mit;
description="Lua binding to libmpack";
homepage="https://github.com/libmpack/libmpack-lua/releases/download/1.0.6/libmpack-lua-1.0.6.tar.gz"; }
;
propagatedBuildInputs=[];
src= fetchurl {
url="https://luarocks.org/mpack-1.0.6-0.src.rock";
sha256="0pydlhgdfbchslizm69h5w5ddalhzaq71hlbl5z2miq7yk9xjs4h"; }
;
version="1.0.6-0"; }
;

ansicolors = buildLuaPackage rec {
propagatedBuildInputs=[ lua];
pname="ansicolors";
src= fetchurl {
sha256="1mhmr090y5394x1j8p44ws17sdwixn5a0r4i052bkfgk3982cqfz";
url="https://luarocks.org/ansicolors-1.0.2-3.src.rock"; }
;
meta={
homepage="https://github.com/kikito/ansicolors.lua";
license=stdenv.lib.licenses.mit;
description="Library for color Manipulation."; }
;
version="1.0.2-3"; }
;

busted = buildLuaPackage rec {
pname="busted";
src= fetchurl {
url="http://luarocks.org/manifests/teto/busted-2.0.rc12-1.src.rock";
sha256="18fzdc7ww4nxwinnw9ah5hi329ghrf0h8xrwcy26lk9qcs9n079z"; }
;
# lacks luasystem
propagatedBuildInputs=[ lua luasystem lua_cliargs luafilesystem dkjson say lua-term luassert ansicolors penlight mediator_lua];
version="2.0.rc12-1";
meta={
homepage="http://olivinelabs.com/busted/";
description="Elegant Lua unit testing.";
license=stdenv.lib.licenses.mit; }
; }
;

dkjson = buildLuaPackage rec {
meta={
license=stdenv.lib.licenses.mit;
description="David Kolf's JSON module for Lua";
homepage="http://dkolf.de/src/dkjson-lua.fsl/"; }
;
src= fetchurl {
sha256="1qy9bzqnb9pf9d48hik4iq8h68aw3270kmax7mmpvvpw7kkyp483";
url="https://luarocks.org/dkjson-2.5-2.src.rock"; }
;
pname="dkjson";
propagatedBuildInputs=[ lua];
version="2.5-2"; }
;
lua-cmsgpack = buildLuaPackage rec {
pname="lua-cmsgpack";
meta={
homepage="http://github.com/antirez/lua-cmsgpack";
description="MessagePack C implementation and bindings for Lua 5.1";
license=stdenv.lib.licenses.mit; }
;
propagatedBuildInputs=[ lua];
version="0.3-2";
src= fetchurl {
url="https://luarocks.org/lua-cmsgpack-0.3-2.src.rock";
sha256="062nk6y99d24qhahwp9ss4q2xhrx40djpl4vgbpmjs8wv0ds84di"; }
; }
;
lua_cliargs = buildLuaPackage rec {
propagatedBuildInputs=[ lua];
version="3.0-1";
src= fetchurl {
sha256="1m17pxirngpm5b1k71rqs8zlwwav1rv52z8d4w8kmj0xn4kvcrfi";
url="https://luarocks.org/lua_cliargs-3.0-1.src.rock"; }
;
pname="lua_cliargs";
meta={
license=stdenv.lib.licenses.mit;
description="A command-line argument parser.";
homepage="https://github.com/amireh/lua_cliargs"; }
; }
;

luassert = buildLuaPackage rec {
version="1.7.10-0";
pname="luassert";
propagatedBuildInputs=[ lua say];
meta={
homepage=http://olivinelabs.com/busted/;
description="Lua Assertions Extension";
license=stdenv.lib.licenses.mit; }
;
src= fetchurl {
url=http://luarocks.org/manifests/teto/luassert-1.7.10-0.src.rock;
sha256="03kd0zhpl2ir0r45z12bayvwahy8pbbcwk1vfphf0zx11ik84rss"; }
; }
;

luv = buildLuaPackage rec {
version="1.9.1-1";
src= fetchurl {
url=https://luarocks.org/luv-1.9.1-1.src.rock;
sha256="1b2gjzk7zixm98ah1xi02k1x2rhl109nqkn1w4jyjfwb3lrbhbfp"; }
;
meta={
homepage=https://github.com/luvit/luv;
license=stdenv.lib.licenses.mit;
description="Bare libuv bindings for lua"; }
;
pname="luv";
propagatedBuildInputs=[ lua]; }
;

nvim-client = buildLuaPackage rec {
meta={
description="Lua client to Nvim";
homepage=https://github.com/neovim/lua-client/archive/0.0.1-26.tar.gz;
license=stdenv.lib.licenses.mit; }
;
pname="nvim-client";
version="0.0.1-26";
src= fetchurl {
sha256="1k3rrii6w2zjmwaanldsbm8fb2d5xzzfwzwjipikxsabivhrm9hs";
url=https://luarocks.org/nvim-client-0.0.1-26.src.rock; }
;
propagatedBuildInputs=[ lua mpack luv coxpcall]; }
;


coxpcall = buildLuaPackage rec {
src= fetchurl {

# url=http://luarocks.org/manifests/teto/coxpcall-scm-1.src.rock;
# sha256="0cz1m32kxi5zx6s69vxdldaafmzqj5wwr69i93abmlz15nx2bqpf";

url=https://luarocks.org/manifests/hisham/coxpcall-1.15.0-1.src.rock;
sha256="0x8hzly5vjmj8xbhg6l2hxhj57ysgrz7afb7wss4pmkc187d74zz";
}
;
version="1.15.0-1";
pname="coxpcall";
propagatedBuildInputs=[];
meta={
license=stdenv.lib.licenses.mit;
description="Coroutine safe xpcall and pcall";
homepage=http://keplerproject.github.io/coxpcall; }
; }
;

say = buildLuaPackage rec {
meta={
description="Lua String Hashing/Indexing Library";
homepage=http://olivinelabs.com/busted/;
license=stdenv.lib.licenses.mit; }
;
src= fetchurl {
sha256="00vvd5yg5f4r1xa0yasb54k452a58sjflbh681cmvr7p0m289ldl";
url=http://luarocks.org/manifests/teto/say-1.3-1.src.rock; }
;
version="1.3-1";
pname="say";
propagatedBuildInputs=[ lua]; }
;

lua-term = buildLuaPackage rec {
meta={
description="Terminal functions for Lua";
homepage="https://github.com/hoelzro/lua-term";
license=stdenv.lib.licenses.mit; }
;
src= fetchurl {
url="https://luarocks.org/lua-term-0.3-1.src.rock";
sha256="1bxfaskb30hpcaz8jmv5mshp56dgxlc2bm6fgf02z556cdy3kapm"; }
;
pname="lua-term";
version="0.3-1";
propagatedBuildInputs=[]; }
;
luasocket = buildLuaPackage rec {
pname="luasocket";
propagatedBuildInputs=[ lua];
version="3.0rc1-2";
meta={
license=stdenv.lib.licenses.mit;
homepage="http://luaforge.net/projects/luasocket/";
description="Network support for the Lua language"; }
;
src= fetchurl {
sha256="1isin9m40ixpqng6ds47skwa4zxrc6w8blza8gmmq566w6hz50iq";
url="https://luarocks.org/luasocket-3.0rc1-2.src.rock"; }
; }
;
ltermbox = buildLuaPackage rec {
propagatedBuildInputs=[ lua];
src= fetchurl {
sha256="08jqlmmskbi1ml1i34dlmg6hxcs60nlm32dahpxhcrgjnfihmyn8";
url="https://luarocks.org/ltermbox-0.2-1.src.rock"; }
;
version="0.2-1";
pname="ltermbox";
meta={
homepage="http://code.google.com/p/termbox";
description="A termbox library package";
license=stdenv.lib.licenses.mit; }
; }
;
luafilesystem = buildLuaPackage rec {
version="1.7.0-2";
src= fetchurl {
url="https://luarocks.org/luafilesystem-1.7.0-2.src.rock";
sha256="0xhmd08zklsgpnpjr9rjipah35fbs8jd4v4va36xd8bpwlvx9rk5"; }
;
pname="luafilesystem";
propagatedBuildInputs=[ lua];
meta={
description="File System Library for the Lua Programming Language";
license=stdenv.lib.licenses.mit;
homepage="git://github.com/keplerproject/luafilesystem"; }
; }
;
penlight = buildLuaPackage rec {
version="1.3.1-1";
pname="penlight";
propagatedBuildInputs=[ luafilesystem];
src= fetchurl {
sha256="10w7yf1n3nrr5ima9aggs9zd7mwiynb29df4vl2qb6ca0p2zrihk";
url="https://luarocks.org/penlight-1.3.1-1.src.rock"; }
;
meta={
description="Lua utility libraries loosely based on the Python standard libraries";
license=stdenv.lib.licenses.mit;
homepage="http://stevedonovan.github.com/Penlight"; }
; }
;
}
