# Matt Post <post@jhu.edu>

package CachePipe;

use strict;
use Exporter;
use vars qw|$VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS|;

# our($lexicon,%rules,%deps,%PARAMS,$base_measure);

@ISA = qw|Exporter|;
@EXPORT = qw|signature file_signature|;
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
	dir     => ".#pipe",
	basedir => $ENV{PWD},
	email   => 'Matt Post <post@jhu.edu>',
  };

  map { $self->{$_} = $params{$_} } keys %params;
  bless($self,$class);

  return $self;
}

sub cmd {
  my ($self,$name,$cmd,@deps) = @_;

  die "no name provided" unless $name ne "";

  my $regenerate = 0;

  my $dir = $self->{dir};
  my $namedir = "$dir/$name";

  if (! -d $dir) {

	$regenerate = 1;

	mkdir($dir);
	mkdir($namedir);

  } elsif (! -d $namedir)  {
	$regenerate = 1;

	mkdir($namedir);

  } elsif (! -e "$namedir/signature") { 
	$regenerate = 1;

  } else {

	my @sigs = map { file_signature($_) } @deps;
	my $new_signature = signature(join(" ", $cmd, @deps));

	open(READ, "$namedir/signature");
	my @file = <READ>;
	close(READ);
	my $old_signature = join("", @file);

	$regenerate = ($old_signature eq $new_signature) ? 0 : 1;
  }

  if ($regenerate) {
	mylog("[$name] rebuilding...");
	map { mylog("  dep=$_"); } @deps;
	mylog("  cmd=$cmd");
	system($cmd);
  }

  # regenerate signature
  my @sigs = map { file_signature($_) } @deps;
  my $new_signature = signature(join(" ", $cmd, @deps));
  open(WRITE, ">$namedir/signature");
  print WRITE $new_signature;
  close(WRITE);
}

# thanks http://stackoverflow.com/questions/552659/assigning-git-sha1s-without-git
sub file_signature {
  my ($filename) = @_;

  open(READ, $filename);
  my @file_contents = <READ>;
  close(READ);

  my $content = join("",@file_contents);

  return signature($content);
}

sub signature {
  my ($content) = @_;

  my $git_blob = 'blob' . ' ' . length($content) . "\0" . $content;

  my $sha1 = new Digest::SHA1;
  $sha1->add($git_blob);

  return $sha1->hexdigest();
}

sub mylog {
	my ($self) = @_;
}

1;

