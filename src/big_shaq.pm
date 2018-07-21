#!/usr/bin/perl
package big_shaq;

use warnings;
use strict;

use Term::ANSIColor;


use lib('.');
use token;
use execute;



sub new {
    my ($class, $args) = @_;

    my $self = {
        file            => $args->{'file'}              || undef,
        content         => [],
        parsed_content  => [],
        tokens          => {},
        function_names  => [],
        variable_names  => [],
        identifier      => 0,
    };

    $self->{'tokens'} = token::get_tokens();
    $self->{'function_names'} = token::get_function_names();
    $self->{'variable_names'} = token::get_variable_names();

    bless $self;
}

sub run {
    my ($self, $file) = @_;

    if (!defined $file && !defined $self->{'file'}) {
        warn "No File given to process!";
        return;
    }

    my $fh;
    if (!open($fh, '<', $file)) {
        warn "Cannot open File '$file'\n\tREASON: $!\n";
        return;
    }

    push (@{$self->{'content'}}, $_) while(<$fh>);
    $self->parse();
    $self->check_parsed();
    my $content = $self->convert_parsed_to_perl();
    
    if (defined $content) {
        my $executer = execute::new();
        $executer->execute($content);
    }
}

sub check_parsed {
    my ($self) = @_;
    $self->check_parsed_functions();
}

sub check_parsed_functions {
    my ($self) = @_;

    my @functions = $self->get_parsed_functions();

    foreach my $element (@{$self->{'parsed_content'}}) {
        my $type = ref($element);
        if ($type eq 'function') {
            my $err = 0;
            foreach my $func (@functions) {
                next if ($func->identifier() eq $element->identifier()); # dont check myself

                # Check if a function is defined multiple times
                if ($func->name() eq $element->name()) {

                    $self->report_syntax_error(
                        "Function '" . $func->name() . "' defined multiple times!\n".
                        "Found in line ".$func->line_begin()." and ". $element->line_begin()
                    );
                    $err = 1;
                }

                # Check if a Function is defined inside of a Function
                if ($element->line_begin() < $func->line_begin &&
                    $element->line_end() >= $func->line_end()) {
                    
                    $self->report_syntax_error(
                        "Function '". $func->name() . "' (line ".$func->line_begin().") defined inside of another Function '". 
                        $element->name() ."' (line ".$element->line_begin().")"
                    );
                    $err = 1;
                }
            }
            if ($err) {
                exit();
            }
        }
    }
}


sub report_syntax_error {
    my ($self, $msg) = @_;

    print color('red on_black');
    $self->print_msg($msg);
}

sub report_warning {
    my ($self, $msg) = @_;

    print color('yellow on_black');
    $self->print_msg($msg);
}

sub print_msg {
    my ($self, $msg) = @_;
    print $msg. "\n";
    print color('reset');
    print "\n";
}

sub get_identifier {
    my ($self) = @_;
    $self->{'identifier'} += 1;
    return $self->{'identifier'};
}

sub get_parsed_functions {
    my ($self) = @_;

    my @funcs;

    foreach my $e (@{$self->{'parsed_content'}}) {
        if (ref($e) eq 'function') {
            push @funcs, $e;
        }
    }
    return @funcs;
}


sub convert_parsed_to_perl {
    my($self) = @_;

    my @perl_content;


    # Check if the first parsed element is a script_start statement
    if (ref(shift(@{$self->{'parsed_content'}})) ne 'script_start') {
        print "Big Shaq is not Ready!\n";
        return undef;
    }

    # Check if the last parsed element is a script_end statement
    if (ref(pop(@{$self->{'parsed_content'}})) ne 'script_end') {
        print "Big Shaq is not done yet!\n";
        return undef;
    }


    foreach my $item (@{$self->{'parsed_content'}}) {
        my $type = ref($item);

        if ($type eq 'function') {
            my $perl_func_name = $self->convert_func_name_to_valid_perl($item->name());
            $perl_content[$item->line_begin()] = 'sub '. $perl_func_name .' {';
            $perl_content[$item->line_end()] = '}'; 
        }
        if ($type eq 'call') {
            $perl_content[$item->line()] = $self->convert_func_name_to_valid_perl($item->function_name()) . "(". $item->parameter().");\n";
        }
    }
    # convert undefined elements into new lines
    $_ = !defined $_ ? "\n" : $_ foreach(@perl_content);
    return \@perl_content;
}


sub convert_func_name_to_valid_perl {
    my ($self, $func_name) = @_;
    $func_name =~ s/-/_/g;
    return $func_name;
}

sub parse {
    my ($self, $content) = @_;

    $self->{'content'} = $content if(defined $content);

    if (!defined $self->{'content'}) {
        warn "Nothing to parse!\n";
        return;
    }

    my $line_counter = 1;
    foreach my $line (@{$self->{'content'}}) {
        my $token = $self->check_token($line);

        if ($token eq 'SCRIPT_START') {
            $self->add_script_start();
        }
        elsif ($token eq 'SCRIPT_END') {
            $self->add_script_end();
        }
        elsif ($token eq 'FUNC_DEF_START') {
            $self->add_func($line, $line_counter);
        }
        elsif ($token eq 'FUNC_DEF_END') {

        }
        elsif ($token eq 'FUNC_CALL') {
            $self->add_func_call($line, $line_counter);
        }
        elsif ($token eq 'PRINT') {
            $self->add_print($line, $line_counter);
        }
        elsif ($token eq 'READ_STDIO') {
            $self->add_read_stdio($line, $line_counter);
        } else {
            if ($line =~ /[^\s]/) {
                chomp($line);
                $self->report_warning(
                    "line $line_counter: '$line' looks like it starts with an unknown keyword - it will be ignored"
                    #"line: '$line'  (line $line_counter) - it will be ignored"
                );
            }
        }
        $line_counter++;
    }
}

sub add_script_end {
    my ($self) = @_;
    $self->append_parsed_content(script_end->new());
}

sub add_script_start {
    my ($self) = @_;
    $self->append_parsed_content(script_start->new());
}

sub check_script_start {
    my ($self) = @_;

    if (scalar($self->{'parsed_content'}) > 0 ) {
        if ($self->{'parsed_content'}[0] ne 'SCRIPT_START') {
            return undef;
        }
    }
    return 1;
}

sub add_read_stdio {
    my ($self, $line, $line_number) = @_;

    my $read = $self->parse_read_stdio($line, $line_number);
    if ($read) {
        $self->append_parsed_content($read);
    }
}

sub parse_read_stdio {
    my ($self, $line, $line_number) = @_;

    if ($line =~ /^\s*\Q$self->{'tokens'}{'READ_STDIO'}\E\s+(.+)$/) {
        my $variable = $1;
        my $call = Read_STDIO->new(
            line            => $line_number,
            variable_name   => $variable,
        );
        return $call;
    }
}

sub add_print {
    my ($self, $line, $line_number) = @_;

    my $print = $self->parse_print($line, $line_number);
    if ($print) {
        $self->append_parsed_content($print);
    }
}

sub add_func_call {
    my ($self, $line, $line_number) = @_;

    my $call = $self->parse_func_call($line, $line_number);
    if ($call) {
        $self->append_parsed_content($call);
    }

}

sub append_parsed_content {
    my ($self, $data) = @_;
    push @{$self->{'parsed_content'}}, $data;
}

sub add_func {
    my ($self, $func_start, $line_number) = @_;

    my $function = $self->parse_func_def_start($func_start, $line_number);
    if ($function) {
        $self->append_parsed_content($function);
    }
}

sub parse_print {
    my ($self, $line, $line_number) = @_;

    if ($line =~ /^\s*\Q$self->{'tokens'}{'PRINT'}\E\s+(.+)$/) {
        my $parameter = "'" . $1 . "'" . '."\n"';
        my $call = call->new(
            line            => $line_number,
            function_name   => 'print',
            parameter       => $parameter,
        );
        return $call;
    }
}

sub parse_func_call {
    my ($self, $line, $line_number) = @_;

    if ($line =~ /^\s*\Q$self->{'tokens'}{'FUNC_CALL'}\E\s+([A-Za-z\-]+)$/) {
        my $func_name = $1;
        my $call = call->new(
            line => $line_number,
            function_name => $func_name,
            parameter => '', # Will maybe be added in the future
        );
        return $call;
    }
}

sub parse_func_def_start {
    my ($self, $func_start, $line_number) = @_;

    if ($func_start =~ /^\s*\Q$self->{'tokens'}{'FUNC_DEF_START'}\E\s+([A-Za-z\-]+)$/) {
        my $func_name = $1;

        my $line_end = $self->look_ahead_func_end($func_name, $line_number);

        if (!$line_end) {
            $line_end = -1;
        }

        my $f = function->new(
            name        => $func_name,
            line_begin  => $line_number,
            line_end    => $line_end,
            identifier  => $self->get_identifier(),
        );
        return $f;
    }
    warn "Could not parse '$func_start' as Function!\n";
    return undef;
}


sub look_ahead_func_end {
    my ($self, $func_name, $line) = @_;

    my $beg = $line;
    my $end = scalar(@{$self->{'content'}});

    for ($beg..$end) {
        my $token = $self->check_token($self->{'content'}[$_]);
        next if(!defined $token);
        if ($token eq 'FUNC_DEF_END') {
            return $_ + 1; # arrays start at 0, line numbers at 1 this is why we need to add 1 to the found line
        }
    }
}

sub check_token {
    my ($self, $str) = @_;
    return undef if (!defined $str);

    foreach my $token (keys %{$self->{'tokens'}}){
        if ($str =~ /^\s*\Q$self->{'tokens'}{$token}\E/) {
            return $token;
        }
    }
}


=head1 big_shaq transpiler
Transpiler to translate '.shaq' programs into perl
As normal user you will B<only> need to B<call> B<big_shaq::new> and B<big_shaq::run>
Everything else is for internal use and you should not and do not need to call!

=head2 Methods

=head3 big_shaq::new()

Method to create a new instance of the big_shaq transpiler

=head3 big_shaq::run()

Parses a given file

=head4 Parameter

=over 2

$self:
$file: File to parse

=back

=head3 big_shaq::convert_parsed_to_perl

Method to convert the parsed content into perl statements

=head4 Returnvalue

=over 2

Returns an array reference with the perl code

=back

=head3 big_shaq::parse()

Function to parse content in the big_shaq format
Parsed content will be saved in C<self{'parsed_content'}>

=head3 big_shaq::check_token()

Function to check if a String starts with one of the known Tokens from C<self-{'tokens'}>
Whitespace is ignored at the beginning of a string

=head4 Return Value

Returns the name of the token that is found.
Does not check if the string matches multiple tokens
if nothing is found, nothing is returned

=cut

1;