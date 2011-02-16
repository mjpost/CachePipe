#!/bin/bash


perl -MCachePipe -e "cache('ls','cp input-file output-file','input-file','output-file','ENV:cachepipe')"
