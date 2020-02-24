#!/usr/bin/env perl

use Test2::V0;
use strictures 2;
use Game::Numberama::Iterator::Column;

subtest 'forward' => sub {
  subtest 'no coords' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
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

  subtest 'no coords modulus width' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '123456789111213141516171819',
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(1 1 5 2 1 1 3 1 6 4 2 1 5 1 7 6 3 1 7 1 8 8 4 1 9 1 9);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator worked as expected when going forward';
  };

  subtest 'with coords' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
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

  subtest 'with invalid coords' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      column => 3,
      row => 40,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    is(dies{$iter->next}, "index out of range\n", 'invalid coords dies on next');
  };

  subtest 'with just column' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      column => 3,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(4 2 5 1 6 3 7 1 8 4 9);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just column worked as expected when going forward';
  };

  subtest 'with just an invalid column' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      column => 30,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    is(dies{$iter->next}, "index out of range\n", 'invalid row dies on next');
  };

  subtest 'with just row' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      row => 1,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(1 2 1 3 1 4 2 5 1 6 3 7 1 8 4 9);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just row worked as expected when going forward';
  };

  subtest 'with just an invalid row' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      row => 50,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    is(dies{$iter->next}, "index out of range\n", 'invalid row dies on next');
  };

  subtest 'with index' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      index => 12,
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 5 1 6 3 7 1 8 4 9);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with index worked as expected when going forward';
  };
};

subtest 'reverse' => sub {
  subtest 'no coords' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
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

  subtest 'no coords modulus width' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '123456789111213141516171819',
      direction => 'reverse',
      width => 9,
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(9 1 9 1 4 8 8 1 7 1 3 6 7 1 5 1 2 4 6 1 3 1 1 2 5 1 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator worked as expected when going forward';
  };

  subtest 'with coords' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
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

  subtest 'with invalid coords' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      column => 3,
      row => 40,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    is(dies{$iter->next}, "index out of range\n", 'invalid coords dies on next');
  };

  subtest 'with just column' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      column => 3,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 4 1 3 1 2 1 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just column worked as expected when going in reverse';
  };

  subtest 'with just an invalid column' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      column => 30,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    is(dies{$iter->next}, "column out of range\n", 'invalid row dies on next');
  };

  subtest 'with just row' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      row => 1,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(4 8 1 7 3 6 1 5 2 4 1 3 1 2 1 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with just row worked as expected when going in reverse';
  };

  subtest 'with just an invalid row' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      row => 50,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';
    is(dies{$iter->next}, "row out of range\n", 'invalid row dies on next');
  };

  subtest 'with index' => sub {
    my $iter = Game::Numberama::Iterator::Column->new(
      data => '12345678911121314',
      index => 12,
      width => 9,
      direction => 'reverse',
    );

    is $iter->current, U(), 'Iterater starts undefined.';

    my @expected = qw(2 4 1 3 1 2 1 1);

    my @got;
    while (my $has = $iter->next) {
      push @got, $has;
    }

    is \@got, \@expected, 'Iterator with index worked as expected when going in reverse';
  };
};

done_testing;
