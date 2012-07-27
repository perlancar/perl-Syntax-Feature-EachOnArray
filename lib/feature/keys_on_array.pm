package feature::keys_on_array; # so as not to confuse dzil?
# VERSION
use strict;
use warnings;
use feature::each_on_array ();
use Carp;
use Scalar::Util qw(reftype);

package Tie::ArrayAsHash;

sub akeys (\[@%]) {
    my $thing = shift;
    return keys %$thing
        if reftype $thing eq 'HASH';
    confess "should be passed a HASH or ARRAY"
        unless reftype $thing eq 'ARRAY';

    my $thing_h = $Tie::ArrayAsHash::cache{$thing} ||= do {
        tie my %h, __PACKAGE__, $thing;
        \%h
    };

    keys %$thing_h;
}

package feature::keys_on_array;

sub import {
    return unless $^V lt 5.12.0;
    no strict 'refs';
    my @caller = caller;
    *{"$caller[0]::keys"} = \&akeys;
}

# XXX on unimport, delete symbol

1;
# ABSTRACT: Emulate keys(@array) on Perl < 5.12

=head1 SYNOPSIS

 # This can run on Perls older than 5.12 and have no effect on 5.12+
 use feature::keys_on_array;

 my @a = (qw/a b c/);
 my @keys = keys @a;


=head1 DESCRIPTION

Beginning with 5.12, Perl supports keys() on array. This module emulates the
support on older Perls.


=head1 CAVEATS

Works on a per-package level, but does not work lexically yet.


=head1 SEE ALSO

L<feature::each_on_array>

L<feature::values_on_array>

=cut
