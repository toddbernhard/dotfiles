#!/usr/bin/env zsh

GSED=${GSED:-$(which sed)}

HMM=$(echo 'Hello world' | GSED -e 's/Hello/Hi/g')
echo $HMM

TEST_BOO="boo"
local TEST_BAZ="baz"
echo $TEST_BAZ
