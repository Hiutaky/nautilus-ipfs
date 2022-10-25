#!/usr/bin/env bash
# Copyright (c) 2022 Keir Finlow-Bates <keir@chainfrog.com>
# Edited by Alessandro De Cristofaro <hiutaky@gmail.com>

# Setup directories
IPFS_PUBLIC=./ipfs-public #change if you already run a public node 
IPFS_PRIVATE=./ipfs-private #this can remain the same

if [ -z "$1" ]
then
    echo "No file to reveal provided."
    exit 1
fi
# First check that ipfs is installed and that the folder to submarine exists
if which ipfs >/dev/null; then
    echo "IPFS installed: proceeding"
else
    echo "Run ./install.sh first"
    exit 1
fi

if [[ ! -d $IPFS_PRIVATE ]]
then
    echo "No private IPFS found - have you run ./install.sh?"
    exit 1
fi

if [[ ! -d $IPFS_PUBLIC ]]
then
    echo "No public IPFS found - have you run ./install.sh?"
    exit 1
fi

if [[ ! -f $1 ]]
then
    echo "File does not exist"
    exit 1
fi

HERE=`echo "$(realpath $0)" | sed 's|\(.*\)/.*|\1|'`
IPFS_PATH=$IPFS_PUBLIC ipfs add --cid-version=1 $1