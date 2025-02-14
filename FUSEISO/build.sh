#!/bin/bash

CUR="$PWD"

LIBFUSE_DIR=$CUR/LIBFUSE

if uname -a | egrep -q 'x86_64|amd64'; then
    name=vtoy_fuse_iso_64
else
    name=vtoy_fuse_iso_32
    opt=-lrt
fi

#
# use musl-c to build for x86_64
#

export C_INCLUDE_PATH=$LIBFUSE_DIR/include

rm -f $name
gcc -specs "/usr/local/musl/lib/musl-gcc.specs" -static -O2 -D_FILE_OFFSET_BITS=64  vtoy_fuse_iso.c $LIBFUSE_DIR/lib/libfuse.a  -o  $name

strip --strip-all $name

if [ -e $name ]; then
   echo -e "\n############### SUCCESS $name ##################\n"
else
    echo -e "\n############### FAILED $name ##################\n"
fi

strip --strip-all $name

