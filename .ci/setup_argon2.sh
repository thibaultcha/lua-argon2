#!/bin/bash

set -e

mkdir -p $ARGON2_DIR
git clone https://github.com/P-H-C/phc-winner-argon2 $ARGON2_DIR
pushd $ARGON2_DIR
make
make test
ln -s libargon2.so libargon2.so.0
popd
