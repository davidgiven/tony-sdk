#!/bin/sh
set -e

mkdir -p chunks
rm -f chunks/*
./bin/dechunker extras/unencryptedrom.img
dot -Tsvg -o extras/callgraph.svg extras/callgraph.dot
echo -n chunks/*.bin | parallel --halt soon,fail=1 --progress --bar --eta -d' ' -n1 \
	'python tools/disassembler.py {} > {.}.S'
