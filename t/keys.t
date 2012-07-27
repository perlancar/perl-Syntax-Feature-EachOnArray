#!perl

use strict;
use warnings;

use Test::More tests => 1;

use feature::keys_on_array;

my @a = (qw/a b c/);
my $s = join "", keys @a;
is($s, "012");
