BEGIN{
  # Avoid Slurp warnings on perl 5.8
  no warnings 'redefine';
  require File::Slurp;
  use warnings;
}
use strict;
use warnings;
package App::CSE;
$App::CSE::VERSION = '0.001';

use Moose;
use Class::Load;
use DateTime;
use String::CamelCase;

use Path::Class::Dir;
use File::stat;
use Getopt::Long qw//;

use Log::Log4perl qw/:easy/;

=head1 NAME

App::CSE - Code search engine. Implements the 'cse' program

=head1 INSTALLATION

Using system wide cpan:

   sudo cpan -i App::CSE

Using cpanm:

   cpanm App::CSE

=head1 SYNOPSIS

  cse

See L<App::CSE::Command::Help> For a description the available commands.

=head1 PROGRAMMATIC USAGE

In addition of using this via the command line program 'cse', you can use this app
in an object oriented way.

For instance:

  my $app = App::CSE->new( { command_name => 'index',
                             options => { 'idx' => '/path/to/the/index' ,
                                           'dir' => '/code/directory/to/index'
                                        });

  if( $app->execute() ){
      .. and error occured ..
  }else{
      .. It is a success ..
  }

Retrieving search hits after a search:

  my $app = App::CSE->new( { command_name => 'search',
                             args => [ 'search_query' ],
                             options => { 'idx' => '/path/to/the/index' ,
                                           'dir' => '/code/directory/to/index'
                                        });
 my $hits = $app->command()->hits();
 # This is a L<Lucy::Search::Hits>

See L<App::CSE::Command::Help> for a list of available commands and options.

=head1 LOGGING

App::CSE uses L<Log::Log4perl>

=head1 BUILD STATUS

=begin html

<a href="https://travis-ci.org/jeteve/App-CSE"><img src="https://travis-ci.org/jeteve/App-CSE.svg?branch=master"></a>

=end html

=head1 COPYRIGHT

See L<App::CSE::Command::Help>

=cut

has 'command_name' => ( is => 'ro', isa => 'Str', required => 1 , lazy_build => 1);
has 'command' => ( is => 'ro', isa => 'App::CSE::Command', lazy_build => 1);
has 'max_size' => ( is => 'ro' , isa => 'Int' , lazy_build => 1);

has 'interactive' => ( is => 'ro' , isa => 'Bool' , default => 0 );

# GetOpt::Long options specs.
has 'options_specs' => ( is => 'ro' , isa => 'ArrayRef[Str]', lazy_build => 1);

# The options as slurped by getopts long
has 'options' => ( is => 'ro' , isa => 'HashRef[Str]', lazy_build => 1);

# The arguments after any option
has 'args' => ( is => 'ro' , isa => 'ArrayRef[Str]', lazy_build => 1);


has 'index_dir' => ( is => 'ro' , isa => 'Path::Class::Dir', lazy_build => 1);
has 'index_mtime' => ( is => 'ro' , isa => 'DateTime' , lazy_build => 1);

sub _build_index_mtime{
  my ($self) = @_;
  my $st = File::stat::stat($self->index_dir());
  return DateTime->from_epoch( epoch => $st->mtime() );
}

sub _build_max_size{
  my ($self) = @_;
  return $self->options()->{max_size} || 1048576; # 1 MB default. This is the buffer size of File::Slurp
}

sub _build_index_dir{
  my ($self) = @_;

  if( my $opt_idx = $self->options->{idx} ){
    return Path::Class::Dir->new($opt_idx);
  }

  return Path::Class::Dir->new('.cse.idx');
}

sub _build_command_name{
  my ($self) = @_;

  unless( $ARGV[0] ){
    return 'help';
  }

  if( $ARGV[0] =~ /^-/ ){
    # The first argv is an option. Assume search
    return 'search';
  }

  ## Ok the first argv is a normal string.
  ## Attempt loading a command class.
  my $command_class = eval{ Class::Load::load_class(__PACKAGE__.'::Command::'.String::CamelCase::camelize($ARGV[0])) };
  if( $command_class ){
    # Valid command class. Return it.
    return shift @ARGV;
  };


  ## This first word is not a valid commnad class.
  ## Assume search.
  return 'search';

}

sub _build_command{
  my ($self) = @_;
  my $command_class = Class::Load::load_class(__PACKAGE__.'::Command::'.String::CamelCase::camelize($self->command_name()));
  my $command = $command_class->new({ cse => $self });
  return $command;
}

sub _build_options_specs{
  my ($self) = @_;
  return $self->command()->options_specs();
}

sub _build_options{
  my ($self) = @_;

  my %options = ();

  my $p = Getopt::Long::Parser->new;
  # Beware that accessing options_specs will consume the command as the first ARGV
  $p->getoptions(\%options , 'idx=s', 'dir=s', 'max-size=i', 'verbose+', @{$self->options_specs()} );
  return \%options;
}

sub _build_args{
  my ($self) = @_;
  $self->options();
  my @args = @ARGV;
  return \@args;
}

my $standard_log = q|
log4perl.rootLogger= INFO, Screen
log4perl.appender.Screen = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr = 0
log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Screen.layout.ConversionPattern=%m%n
|;

my $verbose_log = q|
log4perl.rootLogger= TRACE, Screen
log4perl.appender.Screen = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr = 0
log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = %d [%p] %m%n
|;


sub main{
  my ($self) = @_;

  unless( Log::Log4perl->initialized() ){

    binmode STDOUT , ':utf8';
    binmode STDERR , ':utf8';

    if( $self->options()->{verbose} ){
      Log::Log4perl::init(\$verbose_log);
    }else{
      Log::Log4perl::init(\$standard_log);
    }
  }

  return $self->command()->execute();
}

sub version{
  my ($self) = @_;
  return $App::CSE::VERSION || 'dev';
}

__PACKAGE__->meta->make_immutable();