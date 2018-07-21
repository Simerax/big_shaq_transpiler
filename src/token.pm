#!/usr/bin/perl

package token;

use warnings;
use strict;

use Class::Struct;

struct(
    function => {
        line_begin  => '$', # Line number on which the Function Definition starts
        line_end    => '$', # Line number on which the Function definition ends
        name        => '$', # Name of the Function
        identifier  => '$', # Identifier of the Function, a unique id
    }
);

struct(
    call => {
        line            => '$', # Line number on which the Function is called
        function_name   => '$', # Name of the called Function
        parameter       => '$', # possibly passed parameters to the called function
    }
);

struct(
    read_stdio => {
        line            => '$',
        variable_name   => '$'
    }
);

# Structure to mark a 'SCRIPT_START' token
struct(
    script_start => {
    }
);

# Structure to mark a 'SCRITP_END' token
struct(
    script_end => {
    }
);

my $tokens = {
    SCRIPT_START    => 'Yo, Big Shaq, the one and only',
    SCRIPT_END      => 'Man\'s not hot, never hot. Yeah, Skidika-pap-pap-pap',
    FUNC_DEF_START  => 'the ting goes',
    FUNC_DEF_END    => 'Skidiki-pap-pap-pap-pudrrrr-boom',
    FUNC_CALL       => 'when the ting went',
    PRINT           => 'I tell her',
    READ_STDIO      => 'The girl told me'
};


my $variable_names =   [
                            'pumpy',
                            'big ting',
                            'frisbee',
                            'shew',
                            'twix',
                            'raw sauce',
                            'trees'
];
my $function_tokens =  [
                            'pap',
                            'skidiki',
                            'pudrrrr',
                            'boom',
                            'skidi',
                            'kat',
                            'skrrat',
                            'quack',
                            'ka',
                            'skrrrah'
];

sub get_tokens {
    return $tokens;
}

sub get_token {
    my ($key) = @_;
    return $tokens->{$key} if exists($tokens->{$key});
}

sub get_function_names {
    return $function_tokens;
}

sub get_variable_names {
    return $variable_names;
}

1;
