#!/usr/bin/env perl


use Test2::V0;
use strictures 2;
use Capture::Tiny qw/capture_stdout/;

package TestObj {
  use Moo;
  has width => (
    is => 'ro',
    default => sub {9},
  );
  with "Game::Numberama::Helpers";
  1;
}

my $obj = TestObj->new();

subtest append_unmarked => sub {
  my $board_str = '#2345678###121314';
  my $check = '#2345678###1213142345678121314';
  ok($obj->can('append_unmarked'), 'object can do append_unmarked');
  is($obj->append_unmarked($board_str), $check, 'append_unmarked works');
};

subtest char_at => sub {
  ok($obj->can('char_at'), 'object can do char_at');
  is($obj->char_at('12345678911121314',0,0), 1, '0 works');
  is($obj->char_at('12345678911121314',3,1), 2, '3,1 works');
  is($obj->char_at('12345678911121314',-1,1), '', 'negative column returns empty string');
  is($obj->char_at('12345678911121314',1,-1), '', 'negative row returns empty string');
  is($obj->char_at('12345678911121314',8,4), '', 'row past the last row returns empty string');
  is($obj->char_at('12345678911121314',18,1), '', 'column past the last column returns empty string');
};

subtest coords_at => sub {
  my @coords;
  ok($obj->can('coords_at'), 'object can do coords_at');

  @coords = $obj->coords_at(0);
  is(\@coords, [0,0], '0 works');

  @coords = $obj->coords_at(32);
  is(\@coords, [5,3], '32 works');
};

subtest cross_out => sub {
  my @coords;
  ok($obj->can('cross_out'), 'object can do cross_out');
  my $board_str = '#2345678###121314';
  my $expected  = '##345678###121314';

  my $result = $obj->cross_out($board_str, 1, 0);

  is($result, $expected, 'successfully crossed out the correct one');
  is($board_str, '#2345678###121314', 'board_str is unchanged');
};

subtest format_for_display => sub {
  my $board_str = '#2345678###121314';
  ok($obj->can('format_for_display'), 'object can do format_for_display');

  my $output = $obj->format_for_display($board_str);
  is($output, "#2345678#\n##121314\n", 'got expected board output');
};

subtest index_at => sub {
  ok($obj->can('index_at'), 'object can do index_at');
  is($obj->index_at(0,0), 0, '0 works');
  is($obj->index_at(5,3), 32, '5,3 works');
};

subtest is_neighbor => sub {
  my $board_str = '123456789111#############19#23456789#11213141#16171819';

  #'123456789
  #'111######
  #'#######19
  #'#23456789
  #'#11213141
  #'#16171819

  ok($obj->can('is_neighbor'), 'object can do is_neighbor');
  is($obj->is_neighbor($board_str, 0, 0, 1, 0), T(), 'immediately adjacent east/west');
  is($obj->is_neighbor($board_str, 8, 0, 0, 1), T(), 'immediately adjacent east/west wrap');
  is($obj->is_neighbor($board_str, 2, 1, 7, 2), T(), 'immediately adjacent east/west skip #');
  is($obj->is_neighbor($board_str, 0, 0, 0, 1), T(), 'immediately adjacent north/south');
  is($obj->is_neighbor($board_str, 5, 0, 5, 3), T(), 'immediately adjacent north/south skip #');

  is($obj->is_neighbor($board_str, 0, 0, 2, 0), F(), 'not immediately adjacent east/west');
  is($obj->is_neighbor($board_str, 8, 0, 1, 1), F(), 'not immediately adjacent east/west wrap');

  is($obj->is_neighbor($board_str, 8, 0, 8, 3), F(), 'not immediately adjacent north/south');
  is($obj->is_neighbor($board_str, 0, 0, 0, 2), F(), 'not immediately adjacent north/south');

  is($obj->is_neighbor($board_str, 1, 0, 0, 0), T(), 'immediately adjacent east/west coords swapped');
  is($obj->is_neighbor($board_str, 5, 3, 5, 0), T(), 'immediately adjacent north/south skip # coords swapped');
};

subtest num_left => sub {
  ok($obj->can('num_left'), 'object can do num_left');
  my $board_str = '#2345678###121314';
  is($obj->num_left($board_str), 13, 'num_left works');
};

subtest solved => sub {
  ok($obj->can('solved'), 'object can do solved');
  my $board_str = '12345678911121314';
  is($obj->solved($board_str), F(), 'beginning state is not solved');
  $board_str = '12######911####14';
  is($obj->solved($board_str), F(), 'middle state is not solved');
  $board_str = '#################';
  is($obj->solved($board_str), T(), 'all hashmarks is solved');
};

subtest valid_move => sub {
  ok($obj->can('valid_move'), 'object can do solved'); # DEZ

  my $board_str = '12345678911121314';
  is($obj->valid_move($board_str, 0,0,0,1), T(), 'vertical match of the 1s');
  is($obj->valid_move($board_str, 8,0,0,1), T(), 'horizontal 9 + 1 = 10');
  is($obj->valid_move($board_str, 0,0,1,1), F(), 'not neighbors but are a pair');
  is($obj->valid_move($board_str, 0,0,1,0), F(), 'not equal to 10 or a pair');
  is($obj->valid_move($board_str, 3,0,5,0), F(), 'not neighbors but equal to 10');

  subtest hard => sub {
    my $board_str = '123456789111#############19#23456789#11213141#16171819';
    #'123456789
    #'111######
    #'#######19
    #'#23456789
    #'#11213141
    #'#16171819

    is($obj->valid_move($board_str, 2,1,7,2), T(), 'horizontal match of the 1s, skipping #');
    is($obj->valid_move($board_str, 8,0,8,2), T(), 'horizontal pair of 9s, skipping #');

    is($obj->valid_move($board_str, 0,1,0,2), F(), 'neighbors but one is #');
    is($obj->valid_move($board_str, 0,1,-1,1), F(), 'neighbors but one is empty str');
    is($obj->valid_move($board_str, -1,1,0,1), F(), 'neighbors but one is empty str');
    is($obj->valid_move($board_str, 0,2,0,1), F(), 'neighbors but one is #');
  };
};

done_testing;
