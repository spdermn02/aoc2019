#!/usr/bin/perl 
#===============================================================================
#
#         FILE: t7_2.pl
#
#        USAGE: ./t7_2.pl
#
#  DESCRIPTION: https://adventofcode.com/2019/day/7
#
#  --- Day 7: Amplification Circuit --
#
#       AUTHOR: Lubos Kolouch
#===============================================================================

use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;

my %amplifier;
my %program_param;

sub run_intcode {
my $cur_amp = shift;

# opcodes
#
# 1 - adding, noun, verb, result (3+1)
# 2 - multiply, noun, verb, result (3+1)
# 3 - input, result (1+1)
# 4 - output, result (1+1)
# 5 - jump, zero/nonzero, where (or ignored if zero)
# 6 - jump, zero/nonzero, where if zero (or ignored)
# 7 - less than, if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
# 8 - equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.

    my %params = (
        1 => 3,
        2 => 3,
        3 => 1,
        4 => 1,
        5 => 2,
        6 => 2,
        7 => 3,
        8 => 3,
        99 => 0,
    );

    my %writing_instr = (
        1 => 1,
        2 => 1,
        7 => 1,
        8 => 1,
    );

    # positions : 0 = position mode, 1 = immediate mode
    # ABCDE
    # 1002
    #
    #DE - two-digit opcode,      02 == opcode 2
    # C - mode of 1st parameter,  0 == position mode
    # B - mode of 2nd parameter,  1 == immediate mode
    # A - mode of 3rd parameter,  0 == position mode, omitted due to being a leading zero

    #warn Dumper \$amplifier{$cur_amp};

    my @data = split /,/, $amplifier{$cur_amp}{'program'};

    my $pos = $amplifier{$cur_amp}{'position'};

    while (1) {

        my @instr = split //, $data[$pos];

        my @what;
        my $mode;

        # load the instruction and parameters
        if ( scalar(@instr) == 1 ) {
            unshift @instr, 0;
        }

        my $last = pop @instr // 0;
        my $prev = pop @instr // 0;

        $what[0] = 10 * $prev + $last;

        die unless defined $params{ $what[0] };

        for my $p ( 1 .. $params{ $what[0] } ) {

            $mode = pop @instr // 0;

            if ( ( $mode == 1 ) or ( $data[$pos] == 3 ) ) {
                $what[$p] = $data[ $pos + $p ];
                next;
            }

            if ( ( $p == $params{ $what[0] } ) and ( $writing_instr{ $what[0] } ) ) {
                $what[$p] = $data[ $pos + $p ];
            }
            else {
                $what[$p] = $data[ $data[ $pos + $p ] ];
            }

        }

        if ( $what[0] == 1 ) {
            $data[ $what[3] ] = $what[1] + $what[2];
        }
        elsif ( $what[0] == 2 ) {
            $data[ $what[3] ] = $what[1] * $what[2];
        }
        elsif ( $what[0] == 3 ) {
            if ($amplifier{$cur_amp}{'phase_set'}) {
                $data[ $what[1] ] = $amplifier{$cur_amp}{'input'}
            } else {
                $amplifier{$cur_amp}{'phase_set'} = 1;
                $data[ $what[1] ] = $amplifier{$cur_amp}{'phase'}
            }
        }
        elsif ( $what[0] == 4 ) {
            $amplifier{$cur_amp}{'program'} = join ',', @data;

            my $shift = $params{ $what[0] } + 1;
            $pos += $shift;
            $amplifier{$cur_amp}{'position'} = $pos;

            return $what[1];
        }
        elsif ( $what[0] == 5 ) {
            if ( $what[1] ) {
                $pos = $what[2];
                next;
            }
        }
        elsif ( $what[0] == 6 ) {
            if ( $what[1] == 0 ) {
                $pos = $what[2];
                next;
            }
        }
        elsif ( $what[0] == 7 ) {
            if ( $what[1] < $what[2] ) {
                $data[ $what[3] ] = 1;

            }
            else {
                $data[ $what[3] ] = 0;
            }
        }
        elsif ( $what[0] == 8 ) {

            if ( $what[1] == $what[2] ) {
                $data[ $what[3] ] = 1;
            }
            else {
                $data[ $what[3] ] = 0;
            }
        }
        elsif ( $what[0] == 99 ) {
            $program_param{'program_end'} = 1;
            return "END";

        }
        else {
            die "Unknown argument found";
        }

        my $shift = $params{ $what[0] } + 1;
        $pos += $shift;

    }
}

# -------- MAIN ------------

#open my $file, '<', 'input' or die 'file cannot be opened';

#open my $file, '<', 'input' or die 'file cannot be opened';

#my $program = <$file>;
#chomp $program;

my $program = <<'EOF';
3,8,1001,8,10,8,105,1,0,0,21,38,47,72,97,122,203,284,365,446,99999,3,9,1001,9,3,9,1002,9,5,9,1001,9,4,9,4,9,99,3,9,102,3,9,9,4,9,99,3,9,1001,9,2,9,102,5,9,9,101,3,9,9,1002,9,5,9,101,4,9,9,4,9,99,3,9,101,5,9,9,1002,9,3,9,101,2,9,9,102,3,9,9,1001,9,2,9,4,9,99,3,9,101,3,9,9,102,2,9,9,1001,9,4,9,1002,9,2,9,101,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,99
EOF
chomp $program;

$program_param{'mode'} = 'feedback';
$program_param{'program_end'} = 0;

#my @list = qw/5 6 7 8 9/;
my @list = (0..4) if $program_param{'mode'} eq 'normal';
@list = (5..9) if $program_param{'mode'} eq 'feedback';

my $digit_pattern = '{5,6,7,8,9}' x 5;
my %combs   =
   map  { $_ => 1 }
   grep { ! m{(.).*\1} }
   map  { join q{}, split m{} }
   glob $digit_pattern;

#%combs = ( "98765" => 1);

my $max = 0;
foreach my $comb ( keys %combs ) {
    my @combo = split //, $comb;
    $program_param{'program_end'} = 0;
    my @amp = qw/A B C D E/;

    # initialize the amplifiers

    my $input = 0;

    for my $phase (@combo) {
        my $cur_amp = shift @amp;
        $amplifier{$cur_amp}{'program'}  = $program;
        $amplifier{$cur_amp}{'phase'}    = $phase;
        $amplifier{$cur_amp}{'position'} = 0;
        $amplifier{$cur_amp}{'input'}    = 0;
        $amplifier{$cur_amp}{'output'}   = 0;
        $amplifier{$cur_amp}{'phase_set'}   = 0;
    }

    my $end = 0;
    while ($end == 0) {
        #say "-----------";
        my @amp = qw/A B C D E/;
        # loop through the amplifiers
        for my $amps (0..scalar @amp -1) {
            my $cur_amp = $amp[$amps];
            my $next_amp = $amp[($amps +1) % scalar @amp];

            $amplifier{$next_amp}{'input'} = run_intcode( $cur_amp );

            if (($cur_amp eq 'E') and ($amplifier{$next_amp}{'input'} > $max)) {
                $max = $amplifier{$next_amp}{'input'};
            }

            if ($program_param{'program_end'}) {
                $end = 1;
                last;
            }
            #        say "amp $cur_amp output ".$amplifier{$next_amp}{'input'};
        }

        $end = 1 if $program_param{'mode'} eq 'normal';
    }

}

say $max;