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

=head2 cross_out

Replaces the number at C<$column, $row> with a #.

=cut

sub cross_out {
  my ($self, $board_str, $column, $row) = @_;
  my $index = $self->index_at($column, $row);
  return substr($board_str, $index, 1) = '#';
}

=head2 format_for_display

Formats the board in a human readable way.

=cut

sub format_for_display {
  my ($self, $board_str) = @_;

  return join("\n", unpack('(A' . $self->width . ')*', $board_str)) . "\n";
}

=head2 index_at

Converts a column, row position into a string index.

=cut

sub index_at {
  my ($self, $column, $row) = @_;
  return $self->width * $row + $column;
}

=head2 is_neighbor

Check to ensure that two coords are adjacent
(north / south) or (east / west) ignoring any # between.

=cut

sub is_neighbor {
  my ($self, $board_str, $column1, $row1, $column2, $row2) = @_;

  my $index1 = $self->index_at($column1, $row1);
  my $index2 = $self->index_at($column2, $row2);

  ($index1, $index2) = ($index2, $index1) if $index2 < $index1;

  my $horizontal_distance = abs($index2 - $index1);

  # immediately adjacent east / west (allow for wrap around)
  return 1 if $horizontal_distance == 1;

  # immediately adjacent north / south
  return 1 if $horizontal_distance == 9;

  # adjacent because all between east/west are #
  my $inbetween_horizontal = substr $board_str, $index1+1, $horizontal_distance - 1;
  return 1 if $inbetween_horizontal =~ /^#+$/;
  
  # can't use the iterator here
  # adjacent because all between north / south are #
  if ($column1 == $column2) {
    ($row1, $row2) = ($row2, $row1) if $row2 < $row1;
    my @rows = unpack('(A' . $self->width . ')*', $board_str);
    my $current_row = $row1 + 1;
    while ($current_row < $row2) {
      return 0 unless substr($rows[$current_row], $column1, 1) eq '#';
      $current_row++;
    }
    return 1;
  }

  return 0;
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

=head2 solved

Returns 1 if there are no numbers left.

=cut

sub solved {
  my ($self, $board_str) = @_;

  return $self->num_left($board_str) == 0;
}

=head2 valid_move

Checks to ensure that the numbers at the given coords are valid for a match.

=cut

sub valid_move {
  my ($self, $board_str, $column1, $row1, $column2, $row2) = @_;
  my $char1 = $self->char_at($board_str, $column1, $row1);
  my $char2 = $self->char_at($board_str, $column2, $row2);

  return 0 if ($char1 eq '' || $char2 eq '') or # request for an invalid position
              ($char1 eq '#' || $char2 eq '#'); # a position that has been marked

  return 0 unless $self->is_neighbor($board_str, $column1, $row1, $column2, $row2);

  return 1 if (($char1 eq $char2) || (($char1 + $char2) == 10));

  return 0;
}

1;
