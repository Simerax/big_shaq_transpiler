#!/usr/bin/perl

package token;

use warnings;
use strict;

use Class::Struct;

struct(
    Function => {
        line_begin  => '$',
        line_end    => '$',
        name        => '$',
    }
);

struct(
    Call => {
        line            => '$',
        function_name   => '$',
        parameter       => '$',
    }
);

struct(
    Read_STDIO => {
        line            => '$',
        variable_name   => '$'
    }
);

struct(
    script_start => {
    }
);
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
