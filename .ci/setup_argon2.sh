#!/bin/bash

set -e

git clone https://github.com/P-H-C/phc-winner-argon2.git $ARGON2_DIR
pushd $ARGON2_DIR
  git checkout $ARGON2_VERSION
  make
  make test
popd

