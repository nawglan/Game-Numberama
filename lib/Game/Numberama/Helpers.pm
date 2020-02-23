package Game::Numberama::Helpers;

use strictures 2;
use Moo::Role;

requires 'width';

=head1 METHODS

=head2 append_unmarked

Appends the remaining numbers on the board to the end.
Order is preserved, any occurrance of # is skipped.

=cut

sub append_unmarked {
  my ($self, $board_str) = @_;

  return $board_str .
         join('', grep {$_ ne '#'} split(//, $board_str));
}

=head2 char_at

Returns the character at the given location or C<''> if the location is invalid.

=cut

sub char_at {
  my ($self, $data, $column, $row) = @_;

  # index would be before the beginning of the string
  return '' if $column < 0 || $row < 0;

  my $index = $self->index_at($column, $row);

  # index is past the end of the string
  return '' if $index >= length($data);

  return substr($data, $index, 1);
}

=head2 coords_at

Converts a string index into column, row position.

=cut

sub coords_at {
  my ($self, $index) = @_;

  my $row = int($index / $self->width);
  my $column = $index % $self->width;

  return ($column, $row);
}

=head2 index_at

Converts a column, row position into a string index.

=cut

sub index_at {
  my ($self, $column, $row) = @_;
  return $self->width * $row + $column;
}

=head2 num_left

Returns the number of cells filled with a number.

=cut

sub num_left {
  my ($self, $board_str) = @_;

  my $char = '#';
  my $num_marked =()= $board_str =~ /\Q$char/g;
  return length($board_str) - $num_marked;
}

1;
