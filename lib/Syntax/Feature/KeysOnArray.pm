package Syntax::Feature::KeysOnArray; # so as not to confuse dzil?
# VERSION
use strict;
use warnings;
use Syntax::Feature::EachOnArray ();
use Carp;

package Tie::ArrayAsHash;

sub akeys (\[@%]) {
    my $thing = shift;
    return keys %$thing
        if ref $thing eq 'HASH';
    confess "should be passed a HASH or ARRAY"
        unless ref $thing eq 'ARRAY';

    my $thing_h = $Tie::ArrayAsHash::cache{$thing} ||= do {
        tie my %h, __PACKAGE__, $thing;
        \%h
    };

    keys %$thing_h;
}

package Syntax::Feature::KeysOnArray;

sub install {
    my $class = shift;
    my %args = @_;

    return unless $^V lt 5.12.0;
    no strict 'refs';
    *{"$args{into}::keys"} = \&Tie::ArrayAsHash::akeys;
}

# XXX on uninstall, delete symbol

1;
# ABSTRACT: Emulate keys(@array) on Perl < 5.12

=for Pod::Coverage ^(install)$

=head1 SYNOPSIS

 # This can run on Perls older than 5.12 and have no effect on 5.12+
 use syntax 'keys_on_array';

 my @a = (qw/a b c/);
 my @keys = keys @a;


=head1 DESCRIPTION

Beginning with 5.12, Perl supports keys() on array. This syntax extension
emulates the support on older Perls.


=head1 CAVEATS

No uninstall yet.


=head1 SEE ALSO

L<syntax>

L<Syntax::Feature::EachOnArray>

L<Syntax::Feature::ValuesOnArray>

=cut
