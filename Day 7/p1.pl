
use feature 'say';

my $i = <<'EOF';
3,8,1001,8,10,8,105,1,0,0,21,38,47,72,97,122,203,284,365,446,99999,3,9,1001,9,3,9,1002,9,5,9,1001,9,4,9,4,9,99,3,9,102,3,9,9,4,9,99,3,9,1001,9,2,9,102,5,9,9,101,3,9,9,1002,9,5,9,101,4,9,9,4,9,99,3,9,101,5,9,9,1002,9,3,9,101,2,9,9,102,3,9,9,1001,9,2,9,4,9,99,3,9,101,3,9,9,102,2,9,9,1001,9,4,9,1002,9,2,9,101,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,99
EOF

#$i = <<'EOF';
#3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0
#EOF

my $digit_pattern = '{0,1,2,3,4}' x 5;
my %combs   =
   map  { $_ => 1 }
   grep { ! m{(.).*\1} }
   map  { join q{}, split m{} }
   glob $digit_pattern;

my $max = 0;
my $phase = '';
foreach my $comb ( keys %combs ) {
    my @comb_ar = split(//,$comb);
    my $output = 0;
    my $signal = 0;
    for( my $i = 0; $i < 5; $i++ ) {
        $output = byte_computer($comb_ar[$i],$output);
        #say $output;
        $signal = $output;
    }

    if( $signal > $max ) {
         $max = $signal;
         $phase = $comb;
    }
}

say "Max $max phase $phase";

sub byte_computer {
    my @ar = split(/,/,$i);
    chomp @ar;
    my $i = 0;
    while( $i < scalar(@ar) ) {
        my $opt_part = $ar[$i];
        my $opt = $opt_part % 100;
        my $modeA = $opt_part / 100 % 10;
        my $modeB = $opt_part / 1000 % 10;

        if( $opt == 99 ) { 
            say 'Program Halted';
            exit 1;
        }
        if( $opt == 1 || $opt == 2 ) {
            my $f = $ar[$i+1];
            my $first = ( $modeA ) ? $f: $ar[$f];
            my $s = $ar[$i+2];
            my $second = ( $modeB ) ? $s: $ar[$s];
            $position = $ar[$i+3];
            $val = ( $opt == 2 ) ? $first * $second : $first + $second;
            $i += 4;
        }
        elsif( $opt == 3 ) {
            $val = shift(@_);
            $position = $ar[$i+1];
            $i += 2;
        }
        elsif( $opt == 4 ) {
            my $o = ($modeA) ? $ar[$i+1] : $ar[$ar[$i+1]];
            return $o;
            $i += 2;
            next;
        }
        elsif( $opt == 5 ) {
            $val = ($modeA) ? $ar[$i+1] : $ar[$ar[$i+1]];
            if( $val != 0 )  {
                $i = ( $modeB ) ? $ar[$i+2]: $ar[$ar[$i+2]];
            } else { $i += 3;}
            next;
        }
        elsif( $opt == 6 ) {
            $val = ($modeA) ? $ar[$i+1] : $ar[$ar[$i+1]];
            if( $val == 0 ) {
                $i = ( $modeB ) ? $ar[$i+2]: $ar[$ar[$i+2]];
            } else { $i += 3;}
        
            next;
        }
        elsif( $opt == 7 ) {
             if( (($modeA) ? $ar[$i+1] : $ar[$ar[$i+1]]) < (($modeB) ? $ar[$i+2] : $ar[$ar[$i+2]])   ){
                $ar[$ar[$i+3]] = 1;
             } else { $ar[$ar[$i+3]] = 0; }
             $i += 4;
             next;
        }
        elsif( $opt == 8 ) {
             if( (($modeA) ? $ar[$i+1] : $ar[$ar[$i+1]]) == (($modeB) ? $ar[$i+2] : $ar[$ar[$i+2]])   ){
                $ar[$ar[$i+3]] = 1;
             } else { $ar[$ar[$i+3]] = 0; }
             $i += 4;
             next;
        }
        $ar[$position] = $val;
    }
}
