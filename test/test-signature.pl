#!/usr/bin/perl

use strict;
use warnings;
use CachePipe;

print "The following two lines should be the same\n";
print "a8a940627d132695a9769df883f85992f0ff4a43\n";
print signature("this is a test") . $/;
