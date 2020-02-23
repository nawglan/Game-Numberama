package Game::Numberama::Logic::Simple;

use strictures 2;
use Moo;

=head1 ATTRIBUTES

=head2 width

  The width of the board

=cut

has width => (
  is => 'ro',
  isa => sub {
    die "$_[0] is not a number or is less than or equal to zero"
      unless defined $_[0] && $_[0] + 0 > 0;
  },
  required => 1,
);

with 'Game::Numberama::Helpers';

=head1 METHODS

=head2 find_match

  Decide on a matching pair of numbers or if we want to append.

=cut

sub find_match {
  my ($self, $board_str) = @_;

  return (); # we want to append.
}

1;
