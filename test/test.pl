#!/usr/bin/perl

BEGIN {
  push(@INC, "$ENV{HOME}/code/cachepipe");
}

use strict;
use warnings;
use CachePipe;

my $cache = new CachePipe();

$cache->cmd("ls",
			["input-file"],
			"cp input-file output-file",
			["output-file"]);
