package App::CSE::File::ApplicationXRuby;
{
  $App::CSE::File::ApplicationXRuby::VERSION = '0.008';
}

use Moose;
extends qw/App::CSE::File/;

__PACKAGE__->meta->make_immutable();
