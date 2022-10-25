#!/usr/bin/env bash
# Copyright (c) 2022 Keir Finlow-Bates <keir@chainfrog.com>
# Edited by Alessandro De Cristofaro <hiutaky@gmail.com>

# Setup directories
IPFS_PUBLIC=./ipfs-public #change if you already run a public node
IPFS_PRIVATE=./ipfs-private #this can remain the same

# First check that ipfs is installed and that the folder to submarine exists
if which ipfs >/dev/null; then
    echo "IPFS installed: proceeding"
else
    echo "Run ./install.sh first"
    exit 1
fi

if [[ ! -d ./ipfs-private ]]
then
    echo "No private IPFS found - have you run ./install.sh?"
    exit 1
fi

if [[ ! -d /Users/alessandrodecristofaro/.ipfs/ ]]
then
    echo "No public IPFS found - have you run ./install.sh?"
    exit 1
fi

if [ -z "$1" ]
then
    echo "No folder to submarine provided."
    exit 1
fi

if [[ ! -d "$1" ]]
then
    echo "Folder $1 not found. Exiting."
    exit 1
fi

if [[ -z `ls $1` ]]
then
    echo "There are no files in $1. Exiting."
    exit 1
fi
HERE=`echo "$(realpath $0)" | sed 's|\(.*\)/.*|\1|'`

OUTPUT=`IPFS_PATH=$IPFS_PRIVATE ipfs add --pin=false --recursive --cid-version=1 $1`
FOLDERCID=`echo $OUTPUT | sed 's/.*added bafy/bafy/' | sed 's/ .*//'`

IPFS_PATH=$IPFS_PRIVATE ipfs block get $FOLDERCID > tmp/$FOLDERCID.bin
IPFS_PATH=$IPFS_PRIVATE ipfs repo gc

cat tmp/$FOLDERCID.bin | IPFS_PATH=$IPFS_PUBLIC ipfs dag put --store-codec dag-pb --input-codec dag-pb
IPFS_PATH=$IPFS_PUBLIC ipfs pin add --recursive=false $FOLDERCID

echo "Your folder is now publicly pinned, but you can't see it or the files until you add them individually."
echo
echo "Open the following link to see the folder, but note that the server will hang if you try to view one of the files:"
echo "http://127.0.0.1:5001/ipfs/{{CHANGE_WITH_YOUR}}/#/ipfs/$FOLDERCID"