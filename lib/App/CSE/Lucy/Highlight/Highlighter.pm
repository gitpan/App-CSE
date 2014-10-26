package App::CSE::Lucy::Highlight::Highlighter;
$App::CSE::Lucy::Highlight::Highlighter::VERSION = '0.001';
use base 'Lucy::Highlight::Highlighter';

use strict;
use warnings;

=head2 encode

Overrides the Lucy encode method to avoid any HTMLI-zation.

=cut

use Term::ANSIColor;

sub encode{
  my ($self, $text) = @_;
  return $text;
}

sub highlight{
  my ($self, $text) = @_;
  return colored($text , 'red bold');
}

1;
