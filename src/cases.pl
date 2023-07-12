#!/usr/bin/env perl

use Modern::Perl 2018;
use bignum lib => 'GMP';
use Getopt::Long;

use Algorithm::Combinatorics qw(permutations);

GetOptions(
    'no-paper' => \my $no_paper,
) or die 'failed parsing options';

# All 24 elementary CI statements in four random variables.
my @vars = (
    [[1,2],[]], [[1,2],[3]], [[1,2],[4]], [[1,2],[3,4]],
    [[1,3],[]], [[1,3],[2]], [[1,3],[4]], [[1,3],[2,4]],
    [[1,4],[]], [[1,4],[2]], [[1,4],[3]], [[1,4],[2,3]],
    [[2,3],[]], [[2,3],[1]], [[2,3],[4]], [[2,3],[1,4]],
    [[2,4],[]], [[2,4],[1]], [[2,4],[3]], [[2,4],[1,3]],
    [[3,4],[]], [[3,4],[1]], [[3,4],[2]], [[3,4],[1,2]],
);

# Unique string representation of an element in @vars.
sub face {
    my $face = shift // $_;
    join('', sort($face->[0]->@*)) . '|' . join('', sort($face->[1]->@*))
}

my %lut = map { state $i; face($_) => ++$i } @vars;

# Return the 1-based index of the given $face in @vars.
# This represents a boolean variable in the CNF file format.
sub var {
    my $str = face shift;
    $lut{$str} // die "face $str not found"
}

sub permute {
    my ($p, $face) = @_;
    [
        [ sort map $p->[$_-1], $face->[0]->@* ],
        [ sort map $p->[$_-1], $face->[1]->@* ],
    ]
}

# Forbid support and all supersets.
sub forbid_valid_support {
    my ($cnf, @s) = @_;
    push @$cnf, [ map { - var($_) } @s ];
}

# Forbid support and all subsets.
sub forbid_invalid_support {
    my ($cnf, @s) = @_;
    my %s = map { face($_) => 1 } @s;
    my @rest = grep { not exists $s{face($_)} } @vars;
    push @$cnf, [ map { var($_) } @rest ];
}

my $cnf = [];
my $Sn = permutations([1,2,3,4]);
while (my $p = $Sn->next) {
    # Only allow exchanges 1<->2 and 3<->4.
    next unless
        ($p->[0] == 1 or $p->[0] == 2) and
        ($p->[1] == 1 or $p->[1] == 2) and
        ($p->[2] == 3 or $p->[2] == 4) and
        ($p->[3] == 3 or $p->[3] == 4);

    # Every superset of proved inequalities is out.
    forbid_valid_support($cnf =>
        permute($p => [[3,4],[]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,3],[]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,3],[2]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,2],[3,4]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,3],[2,4]]),
    );

    forbid_valid_support($cnf =>
        permute($p => [[1,2],[]]),
        permute($p => [[1,2],[3]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,2],[3]]),
        permute($p => [[2,4],[3]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,3],[4]]),
        permute($p => [[1,4],[3]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,3],[4]]),
        permute($p => [[3,4],[1]]),
    );
    forbid_valid_support($cnf =>
        permute($p => [[1,3],[4]]),
        permute($p => [[2,3],[4]]),
    );

    # Every subset of refuted inequalities is out.
    forbid_invalid_support($cnf =>
        permute($p => [[1,2],[]]),
        permute($p => [[3,4],[1]]),
        permute($p => [[3,4],[2]]),
        permute($p => [[3,4],[1,2]]),
    );
    forbid_invalid_support($cnf =>
        permute($p => [[1,2],[]]),
        permute($p => [[1,3],[4]]),
        permute($p => [[3,4],[2]]),
        permute($p => [[3,4],[1,2]]),
    );
    forbid_invalid_support($cnf =>
        permute($p => [[1,2],[3]]),
        permute($p => [[1,3],[4]]),
        permute($p => [[3,4],[2]]),
        permute($p => [[3,4],[1,2]]),
    );
    forbid_invalid_support($cnf =>
        permute($p => [[1,2],[3]]),
        permute($p => [[1,2],[4]]),
        permute($p => [[3,4],[1]]),
        permute($p => [[3,4],[2]]),
        permute($p => [[3,4],[1,2]]),
    );
    forbid_invalid_support($cnf =>
        permute($p => [[1,3],[4]]),
        permute($p => [[2,4],[3]]),
    );

    # This is my paper. If I add this, there should be nothing left.
    unless ($no_paper) {
        forbid_invalid_support($cnf =>
            permute($p => [[1,3],[4]]),
            permute($p => [[2,4],[3]]),
            permute($p => [[1,2],[]]),
            permute($p => [[3,4],[1,2]]),
        );
    }
}

# Output the CNF file.
say "p cnf @{[ 0+ @vars ]} @{[ 0+ @$cnf ]}";
say join(' ', @$_, 0) for @$cnf;
say "hello";
