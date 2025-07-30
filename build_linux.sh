#!/usr/bin/env bash -eu

OUT="out/linux"
mkdir -p $OUT
odin build src/linux -out:$OUT/game
cp -R ./assets/ ./$OUT/
echo "Build successful"
