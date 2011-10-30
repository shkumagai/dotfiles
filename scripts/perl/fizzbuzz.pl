#!/usr/bin/env perl

use strict;
use warnings;

sub main {
    my $limit = $ARGV[0] =~ /\d+/ ? $ARGV[0] : 100;

    for my $i (1 .. $limit) {
        my $put = "";
        $put .= "Fizz" if not $i % 3;
        $put .= "Buzz" if not $i % 5;
        $put = $i if $put eq "";
        print "$put\n";
    }
}

main () if(__FILE__ eq $0);
