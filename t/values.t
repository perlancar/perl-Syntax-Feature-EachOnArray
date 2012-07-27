#!perl

use strict;
use warnings;

use Test::More tests => 1;

use feature::values_on_array;

my @a = (qw/a b c/);
my $s = join "", values @a;
is($s, "abc");
