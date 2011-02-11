# Matt Post <post@jhu.edu>

package CachePipe;

use strict;
use Exporter;
use vars qw|$VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS|;

# our($lexicon,%rules,%deps,%PARAMS,$base_measure);

@ISA = qw|Exporter|;
@EXPORT = qw|signature file_signature cache|;
@EXPORT_OK = ();

use strict;
use Carp qw|croak|;
use warnings;
use threads;
use threads::shared;
use POSIX qw|strftime|;
use List::Util qw|reduce min shuffle sum|;
use Digest::SHA1;
# use Memoize;

# my $basedir;
# BEGIN {
#   $basedir = $ENV{CACHEPIPE};
#   unshift @INC, $basedir;
# }

# constructor
sub new {
  my $class = shift;
  my %params = @_;
  # default values
  my $self = { 
	dir     => ".cachepipe",
	basedir => $ENV{PWD},
	email   => undef,
  };

  map { $self->{$_} = $params{$_} } keys %params;
  bless($self,$class);

  return $self;
}

# static version of cmd()
sub cache {
  my @args = @_;
  my $pipe = new CachePipe();
  $pipe->cmd(@args);
}

# Runs a command (if required)
# name: the (unique) name assigned to this command
# input_deps: an array ref of input file dependencies
# cmd: the complete command to run
# output_deps: an array ref of output file dependencies
sub cmd {
  my ($self,$name,$input_deps,$cmd,$output_deps) = @_;

  die "no name provided" unless $name ne "";

  # whether to run the command
  my $regenerate = 0;

  # the directory where cache information is written
  my $dir = $self->{dir};
  my $namedir = "$dir/$name";

  if (! -d $dir) {
	# if no caching has ever been done

	$regenerate = 1;

	mkdir($dir);
	mkdir($namedir);

  } elsif (! -d $namedir)  {
	# otherwise, if this command hasn't yet been cached...
	$regenerate = 1;

	mkdir($namedir);

  } elsif (! -e "$namedir/signature") { 
	# otherwise if the signature file doesn't exist...
	$regenerate = 1;

  } else {
	# everything exists, but we need to check whether anything has changed

	# generate git-style signatures for input and output files
	my @sigs = map { file_signature($_) } @$input_deps;
	push(@sigs, map { file_signature($_) } @$output_deps);

	# generate a signature of the concatenation of the command and the
	# dependency signatures
	# TODO: 
	my $new_signature = signature(join(" ", $cmd, @sigs));

	open(READ, "$namedir/signature") or die "no such file '$namedir/signature'";
	my @file = <READ>;
	close(READ);
	my $old_signature = join("", @file);

	# regenerate if the signature has changed
	$regenerate = ($old_signature eq $new_signature) ? 0 : 1;
  }

  if ($regenerate) {
	$self->mylog("[$name] rebuilding...");
	map { $self->mylog("  input_dep=$_"); } @$input_deps;
	map { $self->mylog("  output_dep=$_"); } @$output_deps;
	$self->mylog("  cmd=$cmd");
	system($cmd);
  } else {
	$self->mylog("[$name] skipping");
  }

  # regenerate signature
  my @sigs = map { file_signature($_) } @$input_deps;
  push(@sigs, map { file_signature($_) } @$output_deps);
  my $new_signature = signature(join(" ", $cmd, @sigs));
  open(WRITE, ">$namedir/signature");
  print WRITE $new_signature;
  close(WRITE);
}

# Generates a GIT-style signature of a file.  Thanks to
# http://stackoverflow.com/questions/552659/assigning-git-sha1s-without-git
sub file_signature {
  my ($filename) = @_;

  my $content = "";
  if (open(READ, $filename)) {
	my @file_contents = <READ>;
	close(READ);

	$content = join("",@file_contents);
  } 

  return signature($content);
}

# Generates a GIT-style signature of a string
sub signature {
  my ($content) = @_;

  my $git_blob = 'blob' . ' ' . length($content) . "\0" . $content;

  my $sha1 = new Digest::SHA1;
  $sha1->add($git_blob);

  return $sha1->hexdigest();
}

sub mylog {
	my ($self,$msg) = @_;

	print STDERR $msg . $/;
}

1;

