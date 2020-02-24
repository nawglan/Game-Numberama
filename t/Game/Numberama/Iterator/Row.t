#!/usr/bin/env perl

use Test2::V0;
use strictures 2;
use Game::Numberama::Iterator::Row;

subtest 'forward' => sub {
  subtest 'no coords' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(1 2 3 4 5 6 7 8 9 1 1 1 2 1 3 1 4);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator worked as expected when going forward';
  };

  subtest 'with coords' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      column => 3,
      row => 1,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 1 3 1 4);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with coords worked as expected when going forward';
  };

  subtest 'with just column' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      column => 3,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(4 5 6 7 8 9 1 1 1 2 1 3 1 4);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just column worked as expected when going forward';
  };

  subtest 'with just row' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      row => 1,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(1 1 1 2 1 3 1 4);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just row worked as expected when going forward';
  };

  subtest 'with index' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      index => 12,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 1 3 1 4);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with index worked as expected when going forward';
  };
};

subtest 'reverse' => sub {
  subtest 'no coords' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      width => 9,
      direction => 'reverse'
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(4 1 3 1 2 1 1 1 9 8 7 6 5 4 3 2 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator worked as expected when going in reverse';
  };

  subtest 'with coords' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      width => 9,
      column => 3,
      row => 1,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 1 1 1 9 8 7 6 5 4 3 2 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with coords worked as expected when going in reverse';
  };

  subtest 'with just column' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      width => 9,
      column => 3,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 1 1 1 9 8 7 6 5 4 3 2 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just column worked as expected when going in reverse';
  };

  subtest 'with just row' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      width => 9,
      row => 1,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(4 1 3 1 2 1 1 1 9 8 7 6 5 4 3 2 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just row worked as expected when going in reverse';
  };

  subtest 'with index' => sub {
    my $iter = Game::Numberama::Iterator::Row->new(
      data => '12345678911121314',
      width => 9,
      index => 12,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 1 1 1 9 8 7 6 5 4 3 2 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with index worked as expected when going in reverse';
  };
};

done_testing;
