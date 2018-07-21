#!/usr/bin/perl
package test::big_shaq;

use warnings;
use strict;
use Module::Loaded;

# In case this file is run in a collection of tests we make sure not to end testing after this file
my $test_is_run_alone = 0;

if ( !is_loaded('Test::More')) {
    use Test::More;
    $test_is_run_alone = 1;
}

sub test {

    # Make sure the Module can be loaded
    Test::More::require_ok("big_shaq")  || Test::More::BAIL_OUT("Can't load Module 'big_shaq'");
    Test::More::require_ok("token")     || Test::More::BAIL_OUT("Can't load Module 'token''");
    #   Run tests
    #

    # Check if parsing of a print statement works
    {
        my $valid_call = "I tell her mans not hot";
        my $line_number = 2;

        my $expected_data = call->new(
                line            => $line_number,
                function_name   => 'print',
                parameter       => '\'mans not hot\'."\n"',
            );

        my $obj = big_shaq::new();
        my $data = $obj->parse_print($valid_call, $line_number);

        Test::More::is_deeply($expected_data, $data, "Parsing a 'Print' Call");
    }

    # Check if parsing of a Function call works
    {
        my $valid_call = "when the ting went pap-pap";
        my $line_number = 2;
        my $expected_data = call->new(
                line            => $line_number,
                function_name   => 'pap-pap',
                parameter       => '',
            );
        my $obj = big_shaq::new();
        my $data = $obj->parse_func_call($valid_call, $line_number);
        Test::More::is_deeply($expected_data, $data, "Parsing a Function Call");
    }

    # Check if parsing of a Function definition works 
    {
        my $valid_call = "the ting goes pap-pap";
        my $line_number = 2;
        my $end_func = 5;
        my $expected_data = function->new(
            name => 'pap-pap',
            line_begin => $line_number,
            line_end   => $end_func, 
            identifier => 1,
        );

        my $obj = big_shaq::new();
        $obj->{'content'}[$end_func -1] = "Skidiki-pap-pap-pap-pudrrrr-boom";
        my $data = $obj->parse_func_def_start($valid_call, $line_number);

        Test::More::is_deeply($expected_data, $data, "Parsing a Function Defintion");
    }

    # end testing in case this is run in standalone
    if ($test_is_run_alone) {
        Test::More::done_testing();
        no Test::More;
    }
}
1;
