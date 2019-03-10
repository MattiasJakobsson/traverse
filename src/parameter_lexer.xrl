Definitions.

WHITESPACE = [\s\t\n\r]
INT = [0-9]+
ATOM = :[a-z_]+
STRING = "[^\"]+"
VARIABLE = [a-zA-Z_.]+
COMPARE_OPERATOR = \=\=|\!\=|\<|\>|\<\=|\>\=

Rules.

{INT} : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
{INT}\.{INT} : {token, {float, TokenLine, list_to_float(TokenChars)}}.
{ATOM} : {token, {atom, TokenLine, to_atom(TokenChars)}}.
{STRING} : {token, {string, TokenLine, extract_string(TokenChars)}}.
{VARIABLE} : {token, {variable, TokenLine, TokenChars}}.
{COMPARE_OPERATOR} : {token, {compare_operator, TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.

Erlang code.

to_atom([$:|Chars]) ->
    list_to_atom(Chars).
    
extract_string(Chars) ->
    list_to_binary(lists:sublist(Chars, 2, length(Chars) - 2)).