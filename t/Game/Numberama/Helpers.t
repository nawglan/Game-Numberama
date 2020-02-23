#!/usr/bin/env perl


use Test2::V0;
use strictures 2;

package TestObj {
  use Moo;
  has width => (
    is => 'ro',
    default => sub {9},
  );
  with "Game::Numberama::Helpers";
}

my $obj = TestObj->new();

ok($obj->can('append_unmarked'), 'object can do append_unmarked');
ok($obj->can('char_at'), 'object can do char_at');
ok($obj->can('coords_at'), 'object can do coords_at');
ok($obj->can('index_at'), 'object can do index_at');
ok($obj->can('num_left'), 'object can do num_left');

subtest append_unmarked => sub {
  my $board_str = '#2345678###121314';
  my $check = '#2345678###1213142345678121314';
  is($obj->append_unmarked($board_str), $check, 'append_unmarked works');
};

subtest char_at => sub {
  is($obj->char_at('12345678911121314',0,0), 1, '0 works');
  is($obj->char_at('12345678911121314',3,1), 2, '3,1 works');
};

subtest coords_at => sub {
  my @coords;
  @coords = $obj->coords_at(0);
  is(\@coords, [0,0], '0 works');

  @coords = $obj->coords_at(32);
  is(\@coords, [5,3], '32 works');
};

subtest index_at => sub {
  is($obj->index_at(0,0), 0, '0 works');
  is($obj->index_at(5,3), 32, '5,3 works');
};

subtest num_left => sub {
  my $board_str = '#2345678###121314';
  is($obj->num_left($board_str), 13, 'num_left works');
};

done_testing;
