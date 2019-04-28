#!/usr/bin/perl

package execute;
use warnings;
use strict;

sub new {
    my ($class, $args) = @_;
    my $self = {

    };
    bless $self;
}

sub execute {
    my ($self, $content, $filename) = @_;

    if (!defined $filename) {
        $filename = "execute.execute";
    }

    while(-f $filename) {
        $filename = $self->generate_random_filename($filename);
    }

    if ($self->write_temp_file($filename, $content)) {
        my $cmd = "perl " . $filename;
        system($cmd);
        unlink $filename;
    }

}

sub write_temp_file {
    my ($self, $filename, $content) = @_;
    my $fh;
    if (!open($fh, '>', $filename)) {
        print "Cannot open file '$filename' for executing script";
        return;
    }

    my $type = ref($content);
    if ($type eq 'ARRAY') {
        foreach my $line (@{$content}) {
            print $fh $line;
        }
    } elsif($type eq 'SCALAR') {
        print $fh $content;
    }else {
        print "Invalid type '$type' in big_shaq::execute()\n";
    }
    close($fh);
    return 1;
}

sub generate_random_filename {
    my ($self, $filename) = @_;

    my $name = "";
    my $min = 65;
    my $max = 90;
    for(1..20) {
        $name .= chr($min + int(rand($max - $min)));
    }

    if (defined $filename) {
        $name .= "_" . $filename;
    }
    return $name;
}

1;
