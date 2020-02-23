#!/usr/bin/env perl

use Test2::V0;
use strictures 2;
use Game::Numberama::Iterators::Column;

subtest 'forward' => sub {
  subtest 'no coords' => sub {
    my $iter = Game::Numberama::Iterators::Column->new(
      data => '12345678911121314',
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(1 1 2 1 3 1 4 2 5 1 6 3 7 1 8 4 9);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator worked as expected when going forward';
  };

  subtest 'with coords' => sub {
    my $iter = Game::Numberama::Iterators::Column->new(
      data => '12345678911121314',
      column => 3,
      row => 1,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 5 1 6 3 7 1 8 4 9);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with coords worked as expected when going forward';
  };
};

subtest 'reverse' => sub {
  subtest 'no coords' => sub {
    my $iter = Game::Numberama::Iterators::Column->new(
      data => '12345678911121314',
      width => 9,
      direction => 'reverse'
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(9 4 8 1 7 3 6 1 5 2 4 1 3 1 2 1 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator worked as expected when going in reverse';
  };

  subtest 'with coords' => sub {
    my $iter = Game::Numberama::Iterators::Column->new(
      data => '12345678911121314',
      column => 3,
      row => 1,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 4 1 3 1 2 1 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with coords worked as expected when going in reverse';
  };
};

done_testing;
