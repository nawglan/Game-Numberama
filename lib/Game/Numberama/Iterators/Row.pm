package Game::Numberama::Iterators::Row;

=pod

=head1 NAME

Game::Numberama::Iterators::Row - An iterator that goes row by row

=head1 SYNOPSIS

  use Game::Numberama::Iterators::Row;

  my $iter = Game::Numberama::Iterators::Row->new(
    column => 0,
    row => 0,
    data => $board_state_str,
    direction => 'forward'
  );

  while (my $char = $iter->next) {
  }

or

  while ($iter->next) {
    my $char = $iter->current;
  }

=head1 DESCRIPTION

An iterator for going row by row.

Given a data string of:

  12345678911121314

this iterator will return 1, 2, 3, 4, etc. when going forward and
4, 1, 3, 1, etc. when going in reverse.

If row and column are passed in, or if index is passed in during creation,
the iterator will start from that position. Otherwise, the iterator will start
from the beginning or end of the board depending on direction.

=cut

use Moo;
use strictures 2;

has data => (
  is => 'ro',
  isa => sub {die "length of data must be greater than 1" unless length $_[0] > 1;},
  required => 1,
);

has direction => (
  is => 'ro',
  isa => sub {die "direction must be forward or reverse." unless $_[0] =~ /forward|reverse/;},
  default => sub {'forward'},
);

has index => (
  is => 'rw',
  default => sub {undef},
);

has row => (
  is => 'rw',
  default => sub {undef},
);

has column => (
  is => 'rw',
  default => sub {undef},
);

has width => (
  is => 'ro',
  required => 1,
);

with "Game::Numberama::Helpers";

sub next {
  my $self = shift;

  if ($self->direction eq 'forward') {
    if (defined $self->index) {
      if ($self->index == length($self->data) - 1) {
        $self->index(undef);
      } else {
        $self->index($self->index + 1);
      }
    } else {
      if (!defined $self->column && !defined $self->row) {
        $self->index(0);
      } else {
        $self->column(0) unless defined $self->column;
        $self->row(0) unless defined $self->row;
        $self->index($self->index_at($self->column, $self->row));
      }
    }
  } else {
    if (defined $self->index) {
      if ($self->index == 0) {
        $self->index(undef);
      } else {
        $self->index($self->index - 1);
      }
    } else {
      if (!defined $self->column && !defined $self->row) {
        my ($c, $r) = $self->coords_at(length($self->data) - 1);
        $self->column($c);
        $self->row($r);
      } elsif (!defined $self->column) {
        $self->column($self->width - 1);
        while ($self->char_at($self->column, $self->row) eq '') {
          my $c = $self->column - 1;
          if ($c >= 0) {
            $self->column($c);
          } else {
            $self->column($self->width - 1);
            my $r = $self->row - 1;
            last if $r == -1;
            $self->row($r);
          }
        }
        die 'Unable to establish starting index.' unless
          $self->char_at($self->column, $self->row) ne '';
      }

      $self->index($self->index_at($self->column, $self->row));
    }
  }

  return defined $self->index ? $self->current : undef;
}

sub current {
  my $self = shift;
  return undef if !defined $self->index;
  return substr($self->data, $self->index, 1) if defined $self->index;
}

1;
