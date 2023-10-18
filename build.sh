#! /bin/bash


INSTALL_PREFIX=${1:-}


if [ -z $TOOLCHAIN_SYSROOT ]; then
	CMAKE_OPTS=""
	TARGET="native"
else
	CMAKE_OPTS="--toolchain ../../cmake-aarch64-libreelec-linux-gnueabi.conf"
	TARGET="jelos"
fi

SRC_DIR=$(mktemp -d -p $(pwd) ${TARGET}.XXX)
BUILD_DIR=${SRC_DIR}

cd LuaJIT-GL
rm -rf build
cmake ${CMAKE_OPTS} -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DLUAJIT_BIN="${BUILD_DIR}/" -Bbuild
cmake --build build --parallel 16 --verbose
cmake --build build -t install
cd ..

cd LuaJIT-SDL2
rm -rf build
cmake ${CMAKE_OPTS} -G"Unix Makefiles" -DSDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS=1 -DCMAKE_BUILD_TYPE=Debug -DLUAJIT_BIN="${BUILD_DIR}/" -Bbuild
cmake --build build --parallel 16 --verbose
cmake --build build -t install
cd ..

cd LuaJIT-ImGui
rm -rf build
cmake ${CMAKE_OPTS} -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DIMPL_GLFW=no -DIMPL_SDL=yes -DIMPL_OPENGL2=no -DIMPL_OPENGL3=yes -DIMPL_OPENGL3_ES2=yes -DSDL_PATH="" -DLUAJIT_BIN="${BUILD_DIR}/" -Bbuild
cmake --build build --parallel 16 --verbose
cmake --build build -t install
cd ..


if [ ! -z "$INSTALL_PREFIX" ]
then
	echo "Will install to ${INSTALL_PREFIX}"
	mkdir -p ${INSTALL_PREFIX}/share/lua/5.1/
	mkdir -p ${INSTALL_PREFIX}/lib/lua/5.1/
	mv ${BUILD_DIR}/lua/* ${INSTALL_PREFIX}/share/lua/5.1/
	rm -r ${BUILD_DIR}/lua
	mv ${BUILD_DIR}/* ${INSTALL_PREFIX}/lib/lua/5.1/
	echo "Activate with:"
	echo "source ${INSTALL_PREFIX}/bin/activate"
	echo "then try by using:"
	echo "lua minimal_sdl_gl31.lua"
else
	echo "package.path = package.path .. \";${BUILD_DIR}/lua/?.lua\"" > ${BUILD_DIR}/minimal_sdl_gl31.lua
	cat minimal_sdl_gl31.lua >> ${BUILD_DIR}/minimal_sdl_gl31.lua
	echo "Built in ${SRC_DIR}, try running:"
	echo "LD_LIBRARY_PATH=$(realpath --relative-to=. ${BUILD_DIR}) luajit $(realpath --relative-to=. ${BUILD_DIR})/minimal_sdl_gl31.lua"
fi

