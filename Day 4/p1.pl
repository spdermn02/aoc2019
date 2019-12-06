
use feature 'say';

my $start = 387638;
my $end = 919123;

my %valid = ();
my $count = 0;
for( my $i = $start; $i < $end; $i++ ){
    my $invalid = 0;
    if( $i =~ /([0-9])\1+/ ) {
        my @nums = split(//,$i);
        my $prev = shift @nums;
        foreach my $n ( @nums ) {
            if( $n < $prev)
            {
                $invalid = 1;
            }
            $prev = $n;
        }
        if( $invalid ) {
            next;
        }
        else {
            $valid{$i} = 1;
            $count++;
        }
    }
    else {
        next;
    }
}
say $count;
#use Data::Dumper;
#say Dumper(\%valid);