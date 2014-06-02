package App::CSE::File::ApplicationXPerl;
{
  $App::CSE::File::ApplicationXPerl::VERSION = '0.004';
}

use Moose;
extends qw/App::CSE::File/;

__PACKAGE__->meta->make_immutable();
