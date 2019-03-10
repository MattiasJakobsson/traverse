Terminals int float atom string true false null '?' '??' ':' variable compare_operator.

Nonterminals expr value compare ternary null_check.

Rootsymbol expr.

value -> null : {const, nil}.
value -> true : {const, true}.
value -> false : {const, false}.
value -> string : {const, extract_token('$1')}.
value -> int : {const, extract_token('$1')}.
value -> float : {const, extract_token('$1')}.
value -> atom : {const, extract_token('$1')}.
value -> variable : {variable, extract_token('$1')}.

compare -> value compare_operator value : {compare, extract_token('$2'), '$1', '$3'}.

ternary -> value '?' expr ':' expr : {ternary, '$1', '$2', '$3'}.
ternary -> variable '?' expr ':' expr : {ternary, '$1', '$2', '$3'}.
ternary -> compare '?' expr ':' expr : {ternary, '$1', '$2', '$3'}.

null_check -> expr '??' expr : {null_check, '$1', '$3'}.

expr -> value : '$1'.
expr -> compare : '$1'.
expr -> ternary : '$1'.
expr -> null_check : '$1'.

Erlang code.
    extract_token({_, _, Value}) -> Value.