#!/usr/bin/perl
use lib('../.');
use lib('../src');

use Test::More;

{
    my $package = "big_shaq";
    testHeader($package);

    use test::big_shaq;
    test::big_shaq::test();
    no test::big_shaq;

    testFooter($package);
};


Test::More::done_testing();

sub testHeader {
    my $header = shift;
    print "-------------------------------------------------------------------\n";
    print "Testing: " . $header . "\n\n";
}

sub testFooter {
    my $footer = shift;
    print "\nDone Testing: $footer\n";
    print "-------------------------------------------------------------------\n";
}

