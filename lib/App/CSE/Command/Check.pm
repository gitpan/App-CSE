package App::CSE::Command::Check;
$App::CSE::Command::Check::VERSION = '0.001';
use Moose;
extends qw/App::CSE::Command/;

use Lucy::Search::IndexSearcher;

use Term::ANSIColor;

use Log::Log4perl;
my $LOGGER = Log::Log4perl->get_logger();

sub execute{
  my ($self) = @_;

  my $index_dir = $self->cse()->index_dir();

  unless( -d  $index_dir ){
    $LOGGER->warn("No index $index_dir. You should run 'cse index'");
    return 1;
  }

  # The directory is there. Check it is a valid lucy index.
  my $lucy = eval{ my $l = Lucy::Search::IndexSearcher->new( index => $index_dir );
                   $l->get_reader();
                   $l->get_schema();
                   $l;
                 };
  unless( $lucy ){
    my $err = $@;
    $LOGGER->error(colored("The index $index_dir is not a valid lucy index.", 'red bold'));
    $LOGGER->debug("Lucy error: $err");
    return 1;
  }

  $LOGGER->info("Index $index_dir is healthy.");
  my $schema = $lucy->get_schema();
  my @fields = sort @{ $schema->all_fields() };
  $LOGGER->info("Fields: ".join(', ', map{ $_.' ('._scrape_lucy_class($schema->fetch_type($_)).')'  } @fields));
  $LOGGER->info($lucy->get_reader()->doc_count().' files indexed on '.$self->cse->index_mtime()->iso8601());
  return 0;
}

sub _scrape_lucy_class{
  my ($o) = @_;
  my $ref = ref($o);
  $ref =~ s/Lucy::Plan:://;
  return $ref;
}

__PACKAGE__->meta->make_immutable();

=head1 NAME

App::CSE::Command::Help - Help about the cse utility

=cut
