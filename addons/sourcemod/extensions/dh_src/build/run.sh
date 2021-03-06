#!/bin/bash

PATH="~/.local/bin:$PATH"
export CXX=clang++ && export CC=clang

cd $(dirname $0)
python3 ../configure.py --sm-path /alliedmodders/sourcemod/ -s csgo
ambuild .
