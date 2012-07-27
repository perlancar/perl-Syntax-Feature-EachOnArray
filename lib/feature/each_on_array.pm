package feature::each_on_array; # don't confuse dzil?

# BEGIN PORTION (c) Toby Inkster
{
	package Tie::ArrayAsHash;

	use strict;
	no warnings;
	use Carp;
	use Hash::FieldHash qw(fieldhash);
	use Scalar::Util qw(reftype);

	use base qw(Exporter);
	BEGIN {
		our @EXPORT_OK = 'aeach';
		$INC{'Tie/ArrayAsHash.pm'} = __FILE__;
	};

	use constant {
		IDX_DATA  => 0,
		IDX_EACH  => 1,
		NEXT_IDX  => 2,
	};

	fieldhash my %cache;

	sub aeach (\[@%])
	{
		my $thing = shift;
		return each %$thing
			if reftype $thing eq 'HASH';
		confess "should be passed a HASH or ARRAY"
			unless reftype $thing eq 'ARRAY';

		my $thing_h = $cache{$thing} ||= do {
			tie my %h, __PACKAGE__, $thing;
			\%h
		};

		each %$thing_h;
	}

	sub TIEHASH
	{
		my ($class, $arrayref) = @_;
		bless [$arrayref, 0] => $class;
	}

	sub STORE
	{
		my ($self, $k, $v) = @_;
		$self->[IDX_DATA][$k] = $v;
	}

	sub FETCH
	{
		my ($self, $k) = @_;
		$self->[IDX_DATA][$k];
	}

	sub FIRSTKEY
	{
		my ($self) = @_;
		$self->[IDX_EACH] = 0;
		$self->NEXTKEY;
	}

	sub NEXTKEY
	{
		my ($self) = @_;
		my $curr = $self->[IDX_EACH]++;
		return if $curr >= @{ $self->[IDX_DATA] };
		return $curr;
	}

	sub EXISTS
	{
		my ($self, $k) = @_;
		!!($k eq $k+0
			and $k < @{ $self->[IDX_DATA] }
		);
	}

	sub DELETE
	{
		my ($self, $k) = @_;
		return pop @{ $self->[IDX_DATA] }
			if @{ $self->[IDX_DATA] } == $k + 1;
		confess "DELETE not fully implemented";
	}

	sub CLEAR
	{
		my ($self) = @_;
		$self->[IDX_DATA] = [];
	}

	sub SCALAR
	{
		my ($self) = @_;
		my %tmp =
			map { $_ => $self->[IDX_DATA][$_] }
			0 .. $#{ $self->[IDX_DATA] };
		return scalar(%tmp);
	}
}
# END PORTION

package feature::each_on_array;

use strict;
use warnings;
use Tie::ArrayAsHash qw(aeach);

sub import {
    return unless $^V lt 5.12.0;
    no strict 'refs';
    my @caller = caller;
    *{"$caller[0]::each"} = \&aeach;
}

# XXX on unimport, delete symbol

1;
# ABSTRACT: Emulate each(@array) on Perl < 5.12

=head1 SYNOPSIS

 # This can run on Perls older than 5.12 and have no effect on 5.12+
 use feature::each_on_array;

 my @a = (qw/a b c/);
 while (my ($idx, $item) = each @a) {
     ...
 }


=head1 DESCRIPTION

Beginning with 5.12, Perl supports each() on array. This module emulates the
support on older Perls.


=head1 CAVEATS

Works on a per-package level, but does not work lexically yet.


=head1 CREDITS

Thanks to Toby Inkster for writing the tie handler.


=head1 SEE ALSO

This module originates from this discussion thread:
L<http://www.perlmonks.org/?node_id=983878>

L<feature::key_on_array>

L<feature::values_on_array>

=cut
