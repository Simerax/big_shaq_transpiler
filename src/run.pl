#!/usr/bin/perl

use warnings;
use strict;
use lib('.');

use big_shaq;

main();

sub main {

    my $file = $ARGV[0];
    if (!defined $file) { 
        print "No File for execution provided!\n";
        print "Try perl $0 example.shaq\n";
        return;
    }

    if (!-f $file) {
        print "File '$file' does not exist.\n";
        return;
    }

    my $transpiler = big_shaq::new();
    $transpiler->run($file);
}
