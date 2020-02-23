package Game::Numberama;

=pod

=head1 NAME

Game::Numberama - Numberama: A game using numbers

=head1 SYNOPSIS

  use Game::Numberama;

  my $game = Game::Numberama->new(input_file => $game_data_file);
  $game->solve;

or with a custom logic package

  my $game = Game::Numberama->new(
    input_file => $game_data_file, logic_package => 'Some::Custom::Logic',
  );
  $game->solve;

=head1 DESCRIPTION

The object of the game is to cross out all numbers on the game board. The game
board is 9 columns wide and N rows long. Only the digits 1-9 are used.

An example starting board:

 123456789
 11121314

Mark crossed out numbers with an #.

To cross out a number, you need to pair it with another number.  To be able to
pair numbers together, they must either be the same digit, or the sum of the
numbers must equal 10.  Also, numbers must be adjacent to each other,
north/south or east/west, ignoring any # between.

Step 1 - match 1 and 1 (north / south)

 #23456789
 #1121314

Step 2 - match 9 and 1 (east / west)

 #2345678#
 ##121314

-or-

Step 1 - match 9 and 1 (east / west)

 12345678#
 #1121314

Step 2 - match 1 and 1 (east / west)

 12345678#
 ###21314

Step 3 - match 8 and 2 (east / west)

 1234567##
 ####1314

-or-

Step 1 - match 1 and 1 (east / west)

 123456789
 ##121314

Step 2 - match 9 and 1 (east / west)

 12345678#
 ###21314

Step 3 - match 8 and 2 (east / west)

 1234567##
 ####1314

If you cannot cross out 2 numbers or choose not to cross out any this turn,
each remaining number is copied to the end, skipping any occurrances of #.

 1234567##
 ####13141
 234567131
 4

Repeat until you have crossed out all numbers.

=cut

use Moo;
use Path::Tiny;
use JSON::XS qw/decode_json encode_json/;
use strictures 2;

=head1 ATTRIBUTES

=head2 bail_out

The game will abort if 500 turns have been reached without a solution.

=cut

has 'bail_out' => (
  is => 'ro',
  isa => sub {die "$_[0] is not 500" unless $_[0] == 500},
  default => sub {500},
);

=head2 board_state

An arrayref containing the state of the board after each move, flattened to a
1d string.

 [
    '12345678911',
    '12345678##1'
 ]

=cut

has board_state => (
  is => 'rw',
);

=head2 input_file

Path to a file with the starting state.

=cut

has input_file => (
  is => 'ro',
  required => 1,
  trigger => 1,
);

sub _trigger_input_file {
  my ($self, $arg) = @_;
  my $file = path($arg)->assert(sub {$_->exists});
  $self->board_state(decode_json($file->slurp));
}

=head2 logic_package

Name of a C<Moo(se)> package providing width attribute and find_match method.
This package will be used like this:

  require $self->logic_package;
  my $logic = $self->logic_package->new(width => 9);
  while ($board_not_solved && $turn < 500) {
    my @move = $logic->find_match($1d_string_of_board_state);
    if (scalar @move == 4) {
      $self->validate_move(@move);
    } else {
      $self->check;
    }
  }

The C<find_match> method should C<return ();> if no match is found or if you
desire the remaining numbers to be appended to the end.

If you find a match, C<find_match> should C<return ($column1, $row1, $column2, $row2);>
This match will be validated, and the board state updated with a # at those
coords.

It is ok to save some state in your Logic package, it remains in scope for the
duration of the run.

=cut

has logic_package => (
  is => 'ro',
  required => 1,
  isa => sub {
    die "$_[0] doesn't look like a package name"
    unless $_[0] =~ /(?:\[a-zA-Z]?[a-zA-Z0-9]*::)*[a-zA-Z]?[a-zA-Z0-9]*/
  },
  default => sub { 'Game::Numberama::Logic::Simple' },
);

=head2 out_file

Path to a file in which to store the state of the board.

=cut

has out_file => (
  is => 'ro',
  lazy => 1,
  default => sub {
    my $self = shift;
    return '/tmp/' . $self->logic_package . $$ . '.json';
  }
);

=head2 verbose

Turns on display of the board to the screen as well as saving the state at the
end of the run.

=cut

has verbose => (
  is => 'ro',
  default => sub {0},
);

=head2 width

The game board is 9 columns wide.

=cut

has 'width' => (
  is => 'ro',
  isa => sub {die "$_[0] is not 9" unless $_[0] == 9},
  default => sub {9},
);

# pull in helpers: index_at($column, $row)
with 'Game::Numberama::Helpers';

=head1 METHODS

=head2 check

Appends the remaining numbers on the board to the end.
Order is preserved, any occurrance of # is skipped.

=cut

sub check {
  my $self = shift;

  push @{$self->board_state}, $self->append_unmarked($self->board_state->[-1]);
}

=head2 cross_out

Replaces the number at C<$column, $row> with a #.

=cut

sub cross_out {
  my ($self, $column, $row) = @_;
  my $index = $self->index_at($column, $row);
  substr($self->board_state->[-1], $index, 1) = '#';
}

=head2 display_board

Prints the board out

=cut

sub display_board {
  my ($self, $turn) = @_;

  print join("\n", split(/.{$self->width}/, $self->board_state->[$turn]));
}

=head2 save_state

Saves the board state to a file.

=cut

sub save_state {
  my $self = shift;
  path($self->out_file)->assert(sub {$_->exists})->spew($self->serialize);
}

=head2 serialize

Returns a JSON encoded string of the board state.

=cut

sub serialize {
  my $self = shift;

  return encode_json($self->board_state);
}

=head2 solve

Attempts to solve the game.

=cut

sub solve {
  my $self = shift;

  require $self->logic_package; # defaults to Game::Numberama::Logic::Simple
  my $logic = $self->logic_package->new(width => $self->width);

  my $turn = (scalar @{$self->board_state}) - 1;
  while ($turn++ < $self->bail_out && !$self->solved) {
    my @move = $logic->find_match($self->board_state->[$turn-1]);
    if (scalar @move == 4) {
      unless ($self->validate_move(@move)) {
        $self->save_state if $self->verbose;
        die "Error, invalid move detected.\n" .
            "Move was: [$move[0], $move[1]], [$move[2], $move[3]]"
      }
    } else {
      $self->check;
    };

    $self->display_board($turn) if $self->verbose;
  }

  $self->save_state if $self->verbose;
  return $self->solved;
}

=head2 solved

Returns 1 if there are no numbers left.

=cut

sub solved {
  my $self = shift;

  return $self->num_left($self->board_state->[-1]) == 0;
}

=head2 validate_move

Checks to ensure that the numbers at the given coords are valid for a match.
If valid, updates the board state by replacing the numbers at these coords
with an #.

=cut

sub validate_move {
  my ($self, $column1, $row1, $column2, $row2) = @_;
  my $char1 = $self->char_at($self->board_state->[-1], $column1, $row1);
  my $char2 = $self->char_at($self->board_state->[-1], $column2, $row2);

  return 0 if ($char1 eq '' || $char2 eq '') or # request for an invalid position
              ($char1 eq '#' || $char2 eq '#'); # a position that has been marked

  if (($char1 eq $char2) || (($char1 + $char2) == 10)) {
    push @{$self->board_state}, $self->board_state->[-1];
    $self->cross_out($column1, $row1);
    $self->cross_out($column2, $row2);
    return 1;
  }

  return 0;
}

1;
