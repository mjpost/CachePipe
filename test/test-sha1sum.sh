#!/bin/bash

set -u

size=$(ls -l $1 | awk '{print $5}')
echo $1 $size
echo "COMMAND LINE"
time (echo -ne "blob $size\0"; cat $1) | sha1sum -b | awk '{print $1}'

echo "PERL"
time perl -MCachePipe -e "print sha1hash('$1') . $/"

