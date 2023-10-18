#! /bin/bash

LUA_DIR=${1:-}

if [ -z "$LUA_DIR" ]
then
	LUA_DIR=$(realpath $(mktemp -d -p . lua.XXXX)/.lenv)
fi
echo ${LUA_DIR}

hererocks ${LUA_DIR} -j @v2.1 -rlatest --verbose
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" config
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install penlight
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install inspect
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install json
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install luafilesystem
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install luaposix
wget https://github.com/rxi/json.lua/raw/master/json.lua -O ${LUA_DIR}/share/lua/5.1/json.lua

luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install nocurses
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install mtmsg
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install auproc
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install ljack
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install losc

luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install luarepl
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install lua-term
luarocks --lua-dir "${LUA_DIR}" --tree "${LUA_DIR}" install luawav

mv ${LUA_DIR}/bin/lua ${LUA_DIR}/bin/_lua
echo "#! /bin/bash
LD_LIBRARY_PATH=\$(dirname \$(realpath \$0))/../lib/lua/5.1/ \$(dirname \$(realpath \$0))/_lua \$@" >> ${LUA_DIR}/bin/lua
chmod +x ${LUA_DIR}/bin/lua

./build.sh ${LUA_DIR}

tar -C $(dirname ${LUA_DIR}) -czf lenv.tar.gz $(basename ${LUA_DIR})