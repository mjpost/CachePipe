#!/usr/bin/perl

BEGIN {
  push(@INC, "$ENV{HOME}/code/cachepipe");
}

use strict;
use warnings;
use CachePipe;

my $cache = new CachePipe();

$cache->cmd("ls",
			"cp input-file output-file",
			"input-file",
			"output-file",
			"ENV:cachepipe"
);
