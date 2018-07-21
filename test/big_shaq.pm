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

        Test::More::is_deeply($expected_data, $data, "big_shaq::parse_print() - Parsing a 'Print' Call");
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
        Test::More::is_deeply($expected_data, $data, "big_shaq::parse_func_call() - Parsing a Function Call");
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

        Test::More::is_deeply($expected_data, $data, "big_shaq::parse_func_def_start() - Parsing a Function Defintion");
    }

    # Check if appending of parsed_content works
    {
        my $expected = script_start->new();
        my $obj = big_shaq::new();
        $obj->append_parsed_content($expected);
        my $got = $obj->{'parsed_content'}[0];
        Test::More::is($got, $expected, "big_shaq::append_parsed_content - Appending Parsed Content");
    }

    # Check if Getting an identifier works
    {
        my $expected = 1;
        my $obj = big_shaq::new();
        my $got = $obj->get_identifier();

        Test::More::is($got, $expected, "big_shaq::get_identifier() - Getting identifier and incrementing it by 1");
    }

    # Check if converting function names works
    {
        my $data = "pap-pap";
        my $expected = "pap_pap";
        my $obj = big_shaq::new();
        my $got = $obj->convert_func_name_to_valid_perl($data);

        Test::More::is($got, $expected, "big_shaq::convert_func_name_to_valid_perl() - Converting Function names");
    }

    # Check if adding a script_start token works
    {
        my $expected = script_start->new();
        my $obj = big_shaq::new();
        $obj->add_script_start();
        my $got = pop(@{$obj->{'parsed_content'}});
        Test::More::is_deeply($got, $expected, "big_shaq::add_script_start() - Adding a 'script_start' to parsed_content");
    }

    # Check if adding a script_end token works
    {
        my $expected = script_end->new();
        my $obj = big_shaq::new();
        $obj->add_script_end();
        my $got = pop(@{$obj->{'parsed_content'}});
        Test::More::is_deeply($got, $expected, "big_shaq::add_script_end() - Adding a 'script_end' to parsed_content");
    }

    # Check if checking for a 'script_start' token works
    {
        my $expected = '1';
        my $obj = big_shaq::new();
        $obj->add_script_start();
        my $got = $obj->check_script_start();
        Test::More::is($got, $expected, "big_shaq::check_script_start() - Checking if the first parsed token is a script_start'");
    }

    # Check if add_read_stdio works
    {
        my $data = 'The girl told me raw sauce';
        my $line_number = 1;
        my $expected = read_stdio->new(
            line => $line_number,
            variable_name => 'raw sauce'
        );
        my $obj = big_shaq::new();

        $obj->add_read_stdio($data, $line_number);
        my $got = pop(@{$obj->{'parsed_content'}});
        Test::More::is_deeply($got, $expected, "big_shaq::add_read_stio() - Adding a read_stdio token");
    }

    # Check if Parsing of a read_stdio works
    {
        my $data = 'The girl told me raw sauce';
        my $line_number = 1;
        my $expected = read_stdio->new(
            line => $line_number,
            variable_name => 'raw sauce',
        );

        my $obj = big_shaq::new();
        my $got = $obj->parse_read_stdio($data, $line_number);

        Test::More::is_deeply($got, $expected, "big_shaq::parse_read_stdio - Parsing a 'Read STDIO' Statement");
    }

    {
        my $data = 'I tell her raw sauce';
        my $line_number = 1;
        my $expected = call->new(
            line            => $line_number,
            function_name   => 'print',
            parameter       => '\'raw sauce\'."\n"',
        );

        my $obj = big_shaq::new();
        $obj->add_print($data, $line_number);
        my $got = pop(@{$obj->{'parsed_content'}});

        Test::More::is_deeply($got, $expected, "big_shaq::add_print - Parsing a 'Read STDIO' Statement");  
    }

    {
        my $test_name = "big_shaq::get_parsed_by_type - Getting Parsed data by type";
        my $obj = big_shaq::new();
        my $expected_call = call->new(
            line => 1,
            function_name => 'abc',
            parameter => ''
        );
        my $filler = script_start->new(); # create some data which should be filtered
        $obj->append_parsed_content($filler);
        $obj->append_parsed_content($expected_call);
        $obj->append_parsed_content($filler);

        my @got = $obj->get_parsed_by_type('call');
        if (scalar @got == 1 && ref($got[0]) eq 'call') {
            Test::More::is_deeply($got[0], $expected_call, $test_name);
        } else {
            fail($test_name);
        }

    }

    # end testing in case this is run in standalone
    if ($test_is_run_alone) {
        Test::More::done_testing();
        no Test::More;
    }
}
1;
