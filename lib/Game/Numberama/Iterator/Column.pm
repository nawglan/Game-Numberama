package Game::Numberama::Iterator::Column;

=pod

=head1 NAME

Game::Numberama::Iterator::Column - An iterator that goes column by column

=head1 SYNOPSIS

  use Game::Numberama::Iterator::Column;

  my $iter = Game::Numberama::Iterator::Column->new(
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

this iterator will return 1, 1, 2, 1, 3, 1, etc. when going forward and
9, 4, 8, 1, 7, 3, 6, etc. when going in reverse.

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

has column => (
  is => 'rw',
  default => sub {undef},
);

has row => (
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
      if (!defined $self->column || !defined $self->row) {
        my ($c, $r) = $self->coords_at($self->index);
        $self->column($c);
        $self->row($r);
      } else {
        my ($c, $r) = $self->coords_at($self->index);
        $self->column($c);
        $self->row($r);

        $r++;
        if ($self->char_at($self->data, $c, $r) eq '') {
          if ($c == $self->width - 1) {
            $self->index(undef);
          } else {
            $self->row(0);
            $self->column($c + 1);
            $self->index($self->index_at($self->column, $self->row));
          }
        } else {
          $self->row($r);
          $self->index($self->index_at($self->column, $self->row));
        }
      }
    } else {
      if (!defined $self->column && !defined $self->row) {
        $self->column(0);
        $self->row(0);
      } else {
        $self->column(0) unless defined $self->column;
        $self->row(0) unless defined $self->row;
      }

      $self->index($self->index_at($self->column, $self->row));
    }
  } else {
    if (defined $self->index) {
      if (!defined $self->column || !defined $self->row) {
        my ($c, $r) = $self->coords_at($self->index);
        $self->column($c);
        $self->row($r);
      } else {
        my ($c, $r) = $self->coords_at($self->index);
        $self->column($c);
        $self->row($r);

        if ($r == 0) {
          if ($c == 0) {
            $self->index(undef);
          } else {
            $c--;
            $r++ while $self->char_at($self->data, $c, $r + 1) ne '';
            $self->column($c);
            $self->row($r);
            $self->index($self->index_at($c, $r));
          }
        } else {
          $r = $self->row - 1;
          $self->row($r);
          $self->index($self->index_at($c, $r));
        }
      }
    } else {
      if (!defined $self->column && !defined $self->row) {
        my $i = length($self->data) - 1;
        $i -= $self->width if length($self->data) % $self->width;  # not an even multiple of width
        my (undef, $r) = $self->coords_at($i);
        $self->row($r);
        $self->column($self->width - 1);
      }

      if (!defined $self->column) {
        my $c = $self->width - 1;
        my $r = $self->row;
        while ($self->char_at($self->data, $c, $r) eq '') {
          $c--;
          if ($c == -1) {
            die "unable to find appropriate starting place";
          }
        }
        $self->column($c);
      } elsif (!defined $self->row) {
        my $r = 0;
        $r++ while $self->char_at($self->data, $self->column, $r + 1) ne '';
        $self->row($r);
      }

      $self->index($self->index_at($self->column, $self->row));
    }
  }

  return defined $self->index ? $self->current : undef;
}

sub current {
  my $self = shift;
  return undef if !defined $self->index;
  return undef if defined $self->index && !defined $self->column || !defined $self->row;
  return substr($self->data, $self->index, 1);
}

1;
