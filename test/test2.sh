#!/bin/bash

. ../bashrc

cachecmd 'ls' 'cp input-file output-file' 'input-file' 'output-file' "ENV:cachepipe" 
