package App::CSE::File::InodeDirectory;
$App::CSE::File::InodeDirectory::VERSION = '0.007';
use Moose;
extends qw/App::CSE::File/;

sub _build_content{
  return undef;
}

__PACKAGE__->meta->make_immutable();
