use feature 'say';

my $i = <<'EOF';
3,8,1001,8,10,8,105,1,0,0,21,38,47,72,97,122,203,284,365,446,99999,3,9,1001,9,3,9,1002,9,5,9,1001,9,4,9,4,9,99,3,9,102,3,9,9,4,9,99,3,9,1001,9,2,9,102,5,9,9,101,3,9,9,1002,9,5,9,101,4,9,9,4,9,99,3,9,101,5,9,9,1002,9,3,9,101,2,9,9,102,3,9,9,1001,9,2,9,4,9,99,3,9,101,3,9,9,102,2,9,9,1001,9,4,9,1002,9,2,9,101,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,99
EOF

$i = <<'EOF';
3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5
EOF

my $digit_pattern = '{5,6,7,8,9}' x 5;
my %combs   =
   map  { $_ => 1 }
   grep { ! m{(.).*\1} }
   map  { join q{}, split m{} }
   glob $digit_pattern;

%combs = ( "98765" => 1);

my $max = 0;
my $phase = '';
foreach my $comb ( keys %combs ) {
    my @comb_ar = split(//,$comb);
    my $output = 0;
    my $signal = 0;
    my $rc = 0;
    my $comp = [{position => 0, data => []},{position => 0, data => []},{position => 0, data => []},{position => 0, data => []},{position => 0, data => []}];
    while($rc == 0){
        for( my $i = 0; $i < 5; $i++ ) {
            #say "output $output";
            ($rc, $output) = byte_computer($comp->[$i],$comb_ar[$i],$output);
            #say $output;
            $signal = $output;
        }
        if( $signal > $max ) {
             $max = $signal;
             $phase = $comb;
say "Max $max phase $phase rc = $rc";
        }
    }

}

say "Max $max phase $phase";

sub byte_computer {
    my $comp = shift @_;
    if( scalar(@{$comp->{data}}) == 0 ) {
        my @ar = split(/,/,$i);
        chomp $ar;
        $comp->{data} = \@ar;
    }
    my $i = ($comp->{position} > 0 ) ? $comp->{position} : 0;
    while( 1) {
        my $opt_part = $comp->{data}->[$i];
        my $opt = $opt_part % 100;
        my $modeA = $opt_part / 100 % 10;
        my $modeB = $opt_part / 1000 % 10;

        if( $opt == 99 ) { 
            say 'Program Halted';
            return (1,0);
        }
        if( $opt == 1 || $opt == 2 ) {
            my $f = $comp->{data}->[$i+1];
            my $first = ( $modeA ) ? $f: $comp->{data}->[$f];
            my $s = $comp->{data}->[$i+2];
            my $second = ( $modeB ) ? $s: $comp->{data}->[$s];
            $position = $comp->{data}->[$i+3];
            $val = ( $opt == 2 ) ? $first * $second : $first + $second;
            $i += 4;
        }
        elsif( $opt == 3 ) {
            $val = shift(@_);
            $position = $comp->{data}->[$i+1];
            $i += 2;
        }
        elsif( $opt == 4 ) {
            my $o = ($modeA) ? $comp->{data}->[$i+1] : $comp->{data}->[$comp->{data}->[$i+1]];
            $i += 2;
            $comp->{position} = $i;
            #say "position $i and $o";
            return (0,$o);
            next;
        }
        elsif( $opt == 5 ) {
            $val = ($modeA) ? $comp->{data}->[$i+1] : $comp->{data}->[$comp->{data}->[$i+1]];
            if( $val != 0 )  {
                $i = ( $modeB ) ? $comp->{data}->[$i+2]: $comp->{data}->[$comp->{data}->[$i+2]];
            } else { $i += 3;}
            next;
        }
        elsif( $opt == 6 ) {
            $val = ($modeA) ? $comp->{data}->[$i+1] : $comp->{data}->[$comp->{data}->[$i+1]];
            if( $val == 0 ) {
                $i = ( $modeB ) ? $comp->{data}->[$i+2]: $comp->{data}->[$comp->{data}->[$i+2]];
            } else { $i += 3;}
        
            next;
        }
        elsif( $opt == 7 ) {
             if( (($modeA) ? $comp->{data}->[$i+1] : $comp->{data}->[$comp->{data}->[$i+1]]) < (($modeB) ? $comp->{data}->[$i+2] : $comp->{data}->[$comp->{data}->[$i+2]])   ){
                $comp->{data}->[$comp->{data}->[$i+3]] = 1;
             } else { $comp->{data}->[$comp->{data}->[$i+3]] = 0; }
             $i += 4;
             next;
        }
        elsif( $opt == 8 ) {
             if( (($modeA) ? $comp->{data}->[$i+1] : $comp->{data}->[$comp->{data}->[$i+1]]) == (($modeB) ? $comp->{data}->[$i+2] : $comp->{data}->[$comp->{data}->[$i+2]])   ){
                $comp->{data}->[$comp->{data}->[$i+3]] = 1;
             } else { $comp->{data}->[$comp->{data}->[$i+3]] = 0; }
             $i += 4;
             next;
        }
        $comp->{data}->[$position] = $val;
    }
}