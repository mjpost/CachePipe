#!/usr/bin/perl

use strict;
use warnings;
use CachePipe;

print "The following two lines should be the same\n";
print "144894520b22ca1bf2881d51a5bb847b39fc3cc0\n";
print signature("this is a test") . $/;
