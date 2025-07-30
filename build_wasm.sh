#!/usr/bin/env bash

OUT="out/wasm"
mkdir -p $OUT
odin build src/wasm -target:js_wasm32 -build-mode:obj -define:RAYLIB_WASM_LIB=env.o -define:RAYGUI_WASM_LIB=env.o -vet -strict-style -out:$OUT/game.wasm.o

ODIN_ROOT=$(odin root)

cp $ODIN_ROOT/core/sys/wasm/js/odin.js $OUT

files="$OUT/game.wasm.o ${ODIN_ROOT}/vendor/raylib/wasm/libraylib.a ${ODIN_ROOT}/vendor/raylib/wasm/libraygui.a"

flags="-sUSE_GLFW=3 -sWASM_BIGINT -sWARN_ON_UNDEFINED_SYMBOLS=0 -sASSERTIONS --shell-file src/wasm/index_template.html --preload-file assets"

emcc -sEXPORTED_RUNTIME_METHODS=HEAPF32 -o $OUT/index.html $files $flags

rm $OUT/game.wasm.o

echo "Build successful"
