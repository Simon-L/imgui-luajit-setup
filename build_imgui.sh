#! /bin/bash


if [[ ! -f "$1/bin/lua" ]]; then
	echo "Provided lua dir doesn't contain lua binary"
	exit 0
fi

INSTALL_PREFIX=${1}

CMAKE_OPTS="-DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_SYSROOT=$TOOLCHAIN_SYSROOT"
TARGET_OS="Rocknix"

BUILD_DIR=$(mktemp -d -p $(pwd) ${TARGET_OS}.XXX)

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
cmake ${CMAKE_OPTS} -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DIMPL_GLFW=no -DIMPL_SDL=yes -DIMPL_OPENGL2=no -DIMPL_OPENGL3=yes -DSDL_PATH="" -DLUAJIT_BIN="${BUILD_DIR}/" -Bbuild
cmake --build build --parallel 16 --verbose
cmake --build build -t install
cd ..

echo "Will install to ${INSTALL_PREFIX}"
mkdir -p ${INSTALL_PREFIX}/share/lua/5.1/
mkdir -p ${INSTALL_PREFIX}/lib/lua/5.1/
mv ${BUILD_DIR}/lua/* ${INSTALL_PREFIX}/share/lua/5.1/
rm -r ${BUILD_DIR}/lua
mv ${BUILD_DIR}/* ${INSTALL_PREFIX}/lib/lua/5.1/

echo "Copy minimal_sdl_gl31.lua to the target and you may run it using:"
echo "LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib/lua/5.1/ ${INSTALL_PREFIX}/bin/lua minimal_sdl_gl31.lua"

