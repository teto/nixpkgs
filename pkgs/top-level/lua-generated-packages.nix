/* ${GENERATED_NIXFILE} is an auto-generated file -- DO NOT EDIT! */
{ self, stdenv
# , buildLuaPackage
# temporary as these get generated eventually
# , luafilesystem, ansicolors
, fetchurl
, fetchgit
}:
with self;
rec {
ansicolors = buildLuaPackage rec {
src= fetchurl {
url="https://github.com/kikito/ansicolors.lua/archive/v1.0.2.tar.gz";
sha256="0r4xi57njldmar9pn77l0vr5701rpmilrm51spv45lz0q9js8xps"; }
;
version="1.0.2-3";
name="ansicolors";
propagatedBuildInputs=[ lua];
meta={
homepage="https://github.com/kikito/ansicolors.lua";
description="Library for color Manipulation.";
license=stdenv.lib.licenses.mit; }
; }
;
busted = buildLuaPackage rec {
version="2.0.rc9-0";
name="busted";
src= fetchurl {
sha256="0snaxcq60fj86i75b5lq3d60pd05xzpz1w4qslhm228g8rc0kg4b";
url="https://github.com/Olivine-Labs/busted/archive/v2.0.rc9-0.tar.gz"; }
;
meta={
description="Elegant Lua unit testing.";
license=stdenv.lib.licenses.mit;
homepage="http://olivinelabs.com/busted/"; }
;
propagatedBuildInputs=[ lua lua_cliargs luafilesystem dkjson say luassert ansicolors lua-term penlight mediator_lua luasocket]; }
;
dkjson = buildLuaPackage rec {
src= fetchurl {
url="http://dkolf.de/src/dkjson-lua.fsl/tarball/dkjson-2.5.tar.gz?uuid=release_2_5";
sha256="14wanday1l7wj2lnpabbxw8rcsa0zbvcdi1w88rdr5gbsq3xwasm"; }
;
propagatedBuildInputs=[ lua];
meta={
homepage="http://dkolf.de/src/dkjson-lua.fsl/";
license=stdenv.lib.licenses.mit;
description="David Kolf's JSON module for Lua"; }
;
version="2.5-2";
name="dkjson"; }
;
lua-cmsgpack = buildLuaPackage rec {
propagatedBuildInputs=[ lua];
meta={
description="MessagePack C implementation and bindings for Lua 5.1/5.2/5.3";
license=stdenv.lib.licenses.mit;
homepage="http://github.com/antirez/lua-cmsgpack"; }
;
src= fetchfromgit {
url="git://github.com/antirez/lua-cmsgpack.git";
sha256="0j0ahc9rprgl6dqxybaxggjam2r5i2wqqsd6764n0d7fdpj9fqm0";
rev="0.4.0"; }
;
version="0.4.0-0";
name="lua-cmsgpack"; }
;
lua_cliargs = buildLuaPackage rec {
  propagatedBuildInputs=[ lua];
  src= fetchurl {
    sha256="15sh7d0xwpgfsb346nzc0abj81wkrf9s8iyfrfclyr3wmiyg89d9";
    url="https://github.com/downloads/amireh/lua_cliargs/lua_cliargs-1.1.tar.gz"; }
    ;
    version="1.1-1";
    name="lua_cliargs";
    meta={
      homepage="https://github.com/amireh/lua_cliargs";
      description="A command-line argument parser.";
      # license=stdenv.lib.licenses.mit;
    } ;
};
luassert = buildLuaPackage rec {
meta={
description="Lua Assertions Extension";
homepage="http://olivinelabs.com/busted/";
license=stdenv.lib.licenses.mit; }
;
propagatedBuildInputs=[ lua say];
name="luassert";
src= fetchurl {
sha256="0qgi3xcm3j6mqk4crc1mwwbj74aw5mjjn93hcf8c9bcvh7sf6cp6";
url="https://github.com/Olivine-Labs/luassert/archive/v1.7.9.tar.gz"; }
;
version="1.7.9-0"; }
;
lua-term = buildLuaPackage rec {
meta={
description="Terminal functions for Lua";
homepage="https://github.com/hoelzro/lua-term";
license=stdenv.lib.licenses.mit; }
;
propagatedBuildInputs=[];
name="lua-term";
version="0.7-1";
src= fetchurl {
sha256="0c3zc0cl3a5pbdn056vnlan16g0wimv0p9bq52h7w507f72x18f1";
url="https://github.com/hoelzro/lua-term/archive/0.07.tar.gz"; }
; }
;
luasocket = buildLuaPackage rec {
propagatedBuildInputs=[ lua];
name="luasocket";
src= fetchurl {
url="http://luaforge.net/frs/download.php/2664/luasocket-2.0.2.tar.gz";
sha256="19ichkbc4rxv00ggz8gyf29jibvc2wq9pqjik0ll326rrxswgnag"; }
;
meta={
homepage="http://luaforge.net/projects/luasocket/";
license=stdenv.lib.licenses.mit;
description="Network support for the Lua language"; }
;
version="2.0.2-6"; }
;
ltermbox = buildLuaPackage rec {
src= fetchfromgit {
rev="v0.2";
url="git://github.com/ukasz/termbox.git";
sha256="0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5"; }
;
propagatedBuildInputs=[ lua];
name="ltermbox";
version="0.2-1";
meta={
license=stdenv.lib.licenses.mit;
homepage="http://code.google.com/p/termbox";
description="A termbox library package"; }
; }
;
mediator_lua = buildLuaPackage rec {
src= fetchurl {
sha256="0z1nzc0jf6sri8imbcxy8ijn9scqn2jnhfcnn3rfj96izilj7qhg";
url="https://github.com/Olivine-Labs/mediator_lua/archive/v1.1.tar.gz"; }
;
propagatedBuildInputs=[ lua];
meta={
description="Event handling through channels";
homepage="http://olivinelabs.com/mediator_lua/";
license=stdenv.lib.licenses.mit; }
;
name="mediator_lua";
version="1.1-3"; }
;
penlight = buildLuaPackage rec {
version="1.5.4-1";
name="penlight";
propagatedBuildInputs=[ luafilesystem];
meta={
homepage="http://stevedonovan.github.com/Penlight";
description="Lua utility libraries loosely based on the Python standard libraries";
license=stdenv.lib.licenses.mit; }
;
src= fetchurl {
url="http://stevedonovan.github.io/files/penlight-1.5.4.zip";
sha256="138f921p6kdqkmf4pz115phhj0jsqf28g33avws80d2vq2ixqm8q"; }
; }
;
say = buildLuaPackage rec {
propagatedBuildInputs=[ lua];
version="1.3-1";
name="say";
src= fetchurl {
url="https://github.com/Olivine-Labs/say/archive/v1.3-1.tar.gz";
sha256="1jh76mxq9dcmv7kps2spwcc6895jmj2sf04i4y9idaxlicvwvs13"; }
;
meta={
license=stdenv.lib.licenses.mit;
homepage="http://olivinelabs.com/busted/";
description="Lua String Hashing/Indexing Library"; }
; }
;
}
