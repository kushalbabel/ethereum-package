#!/usr/bin/env bash

set -e
set -x

if [[ "$SGX" == 1 ]]; then
    GRAMINE="gramine-sgx"
else
    GRAMINE="gramine-direct"
fi
mkdir -p /data/
mkdir -p /shared/
mkdir -p /cert/

./geth --datadir=/data init /etc/genesis/genesis.json

gramine-sgx-sigstruct-view --output-format json geth.sig > /shared/builder_enclave.json

$GRAMINE ./geth
