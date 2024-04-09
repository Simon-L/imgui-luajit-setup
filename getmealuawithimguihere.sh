#! /bin/bash

LUA_DIR=${1:-}

if [ -z "$LUA_DIR" ]
then
	LUA_DIR=$(realpath $(mktemp -d -p . lua.XXXX)/.lenv)
fi
echo ${LUA_DIR}

# A build of luajit for the host is needed to run luarocks against the target tree
# unset $CROSS to force host gcc
CROSS= python ./hererocks/hererocks.py host -j @v2.1 --verbose

# This will build with environment variable CROSS
python ./hererocks/hererocks.py ${LUA_DIR} -j @v2.1 -rlatest --verbose

# Use host lua to run luarocks (which is a lua script!) against the target tree
# Here $CC is used for cross platform
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" config
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install penlight
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install inspect
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install json
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install luafilesystem
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install luaposix
wget https://github.com/rxi/json.lua/raw/master/json.lua -O ${LUA_DIR}/share/lua/5.1/json.lua

host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install nocurses
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install mtmsg
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install auproc
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install ljack
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install losc

host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install luarepl
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install lua-term
host/bin/lua ${LUA_DIR}/bin/luarocks --tree "${LUA_DIR}" install luawav

													# ^ was here --lua-dir "${LUA_DIR}"
# mv ${LUA_DIR}/bin/lua ${LUA_DIR}/bin/_lua
# echo "#! /bin/bash
# LD_LIBRARY_PATH=\$(dirname \$(realpath \$0))/../lib/lua/5.1/ \$(dirname \$(realpath \$0))/_lua \$@" >> ${LUA_DIR}/bin/lua
# chmod +x ${LUA_DIR}/bin/lua
# 
# ./build.sh ${LUA_DIR}
# 
# tar -C $(dirname ${LUA_DIR}) -czf lenv.tar.gz $(basename ${LUA_DIR})

