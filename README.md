# big_shaq_transpiler
A transpiler to Perl from phrases of the rapper "Big Shaq"

## Requirements
To run a script you need to have Perl installed.
Only tested with **Perl Version 5.24.1**

## Installation
1. Clone the repository 
`git https://github.com/Simerax/big_shaq_transpiler`

2. Go to `src`
Execute `perl run.pl example.shaq`

3. Hope everything worked
In case it didn't check the error Message and make sure you resolve the problems if possible
If you think you found a bug create a new Issue.


## Syntax

**IMPORTANT**

*Programs are Case Sensitive!*

*No Error Checking so far!*


Every *.shaq* program has to start with following line
`Yo, Big Shaq, the one and only`

The last line of the Programm has to be 
`Man's not hot, never hot. Yeah, Skidika-pap-pap-pap`


#### Print Statement / Writing to STDOUT
You can write to STDOUT with the call `I tell her`

Example to write *Mans not hot*

    I tell her Mans not hot

#### Function definition
A Function can be defined by typing `the ting goes` followed by a Function name.
Every line that follows is part of that function until the function is ended by typing `Skidiki-pap-pap-pap-pudrrrr-boom`

Example:

    the ting goes pap-pap
        ...
    Skidiki-pap-pap-pap-pudrrrr-boom

#### Calling a Function
A Function can be called with `when the ting went` followed by the function name.
Function Parameters are not supported so far.

Example:

    when the ting went pap-pap
