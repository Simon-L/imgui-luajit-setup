#! /bin/bash

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

echo "package.path = package.path .. \";${BUILD_DIR}/lua/?.lua\"" > ${BUILD_DIR}/minimal_sdl.lua
cat LuaJIT-ImGui/examples/minimal_sdl.lua >> ${BUILD_DIR}/minimal_sdl.lua

echo "\nBuilt in ${SRC_DIR}, try running:"
echo "LD_LIBRARY_PATH=$(realpath --relative-to=. ${BUILD_DIR}) luajit $(realpath --relative-to=. ${BUILD_DIR})/minimal_sdl.lua"
