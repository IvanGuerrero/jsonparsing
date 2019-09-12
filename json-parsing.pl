
%%%% -*- Mode: Prolog -*-
%%%% 816335 Bryan Ivan Zhigui Guerrero
%%%% predicati di controllo di caratteri

is_double_quotes('"').

is_quote('\'').

is_not_toquote_1(C) :-
        C \== 34.
        %char_type(C, ascii).

is_not_toquote_2(C) :-
        C \== 39.
        %char_type(C, ascii).

is_parengout('}').

is_parengin('{').

is_space(C) :-
        char_type(C, space),
        !.

is_space('|').

is_doublepunct(:).

is_dash(-).

is_comma(',').

is_digit(C) :-
        char_type(C, digit).

is_punct('.').

is_parenq_in('[').

is_parenq_out(']').

is_empty(List, Out):-
        delete_space(List, Out).

%%%%delete_space/2, prendi in input di lista di caratteri e restituisce una lista
%%%%di caratteri eliminando gli spazi

delete_space([In],[]) :-
        is_space(In),
        !.
delete_space([In| More] ,Out ) :-
        is_space(In),
        !,
        delete_space(More, Out).
delete_space(List, List) :-
        ! .

delete_double_quote([In| More], More) :-
        is_doublepunct(In),
        !.
%%%% any_chars_not_dquote/1 prende in input un carattere e va a verificare che sia diverso
%%%% dalla definizione del predicato double quote (stessa cosa per il predicato any_chars_not quote)

any_chars_not_dquote(CharIn) :-
        is_not_toquote_2(CharIn),
        !.
any_chars_not_dquote(CharIn) :-
        is_double_quotes(CharIn),
        ! .
any_chars_not_dquote(CharIn) :-
        is_space(CharIn),
        ! .
any_chars_not_quote(CharIn) :-
        is_not_toquote_1(CharIn),
        !.
any_chars_not_quote(CharIn) :-
        is_quote(CharIn),
        ! .
any_chars_not_quote(CharIn) :-
        is_space(CharIn),
        ! .

%%%% sublist_quote/2, prende in input una lista di caratteri e come output mi da una nuova lista
%%%% di caratteri (la stringa) senza l'ultimo apice(che chiude la stringa)

sublist_quote([In | _] , []) :-
        is_quote(In),
        ! .
sublist_quote([In | MoreList] , [In | Zs]) :-
        any_chars_not_dquote(In),
        sublist_quote(MoreList , Zs),
        !.
%%%% sublist_double_quote/2 ha la stessa funzionalità della
%%%% sublist_quote/2 ma considerando i doppi apici.

sublist_double_quote([In | _] ,[]) :-
        is_double_quotes(In),
        ! .
sublist_double_quote([In | MoreList] , [In | Zs]) :-
        any_chars_not_quote(In),
        sublist_double_quote(MoreList, Zs),
        !.

%%%% json_digit/2, prende in input una lista di caratteri che
%%%% ricorsivamente vengono controllati se iniziano con (+/-) e
%%%% i caratteri che seguono sono effettivamente dei numeri.
%%%% Restituisce in output una lista di caratteri contente il segno e i
%%%% numeri.

json_digit([In| MoreNum], [In| Zs]) :-
        is_dash(In),
        ! ,
        json_digit(MoreNum, Zs).
json_digit([In| MoreNum], [In| Zs]) :-
        is_digit(In),
        ! ,
        json_digit(MoreNum, Zs).
json_digit([In | MoreNum], [In| Zs] ) :-
        is_punct(In),
        ! ,
        json_digit(MoreNum, Zs).
json_digit([In| _],[]) :-
        is_comma(In),
        ! .
json_digit([In |_],[]) :-
        is_parengout(In),
        !.

json_digit([In | _],[]) :-
        is_space(In),
        !.

json_digit([In | _],[]) :-
        is_parenq_out(In).


%%%% json_number/3 prende in input un lista di caratteri, restituendo
%%%% in output il numero (convertito da lista di caratteri ottenuta
%%%% dalla json_digit), il secondo parametro tiene conto di
%%%% come la lista di caratteri iniziale viene ridotta.

json_number(Input, SubList, Number) :-
        json_digit(Input, ListNumber ),
        append(ListNumber, SubList, Input),
        !,
        number_chars(Number, ListNumber).

%%%% json_string/2 prende in input la lista di caratteri iniziale e in
%%%% output restituisce la stringa(convertita da lista di caratteri
%%%% ottenuta dalla sublist_quote), il secondo parametro tiene conto di
%%%% come la lista di caratteri iniziale viene ridotta.

json_string([In | MoreSub] , SubList, String) :-
        is_quote(In),
        sublist_quote(MoreSub, ListStr),
        append(ListStr, ['\''],SubStr),
        append(SubStr, SubList, MoreSub),
        ! ,
        string_chars(String, ListStr).
json_string([In | MoreSub], SubList, String) :-
        is_double_quotes(In),
        sublist_double_quote(MoreSub, ListStr),
        append(ListStr, ['"'],SubStr),
        append(SubStr, SubList, MoreSub),
        !,
        string_chars(String, ListStr).

%%%% json_value/3 (value identificato come stringa).

json_value(ListIn,SubList, ValueString) :-
        json_string(ListIn, SubList, ValueString),
         !.

%%%% json_value/3 (value identificato come numero).

json_value(ListIn, SubList,ValueNum) :-
        json_number(ListIn, SubList, ValueNum),
        !.
%%%% json_value/3 (value identificato come json_obj/json_array).

json_value(ListIn, SubList, Value) :-
         json(ListIn,SubList, Value),
        ! .

%%%% json_pair/2 restituisce una coppia di valori
%%%% contente una chiave(di tipo string) e un valore (di tipo value).

json_pair(List, ListOut,(Key, Value)):-
        delete_space(List, ListIn),
        json_string(ListIn, NewList, Key),
        delete_space(NewList,OutSpace),
        delete_double_quote(OutSpace,OutQuote),
        delete_space(OutQuote, NewSubIn),
        json_value(NewSubIn, SubListOut, Value),
        delete_space(SubListOut, ListOut),
        ! .

%%%% json_members/2 restituisce una lista di pair.

json_members(List, SubList, [(Key, Value)|MoreMembers]) :-
        json_pair(List, SubListi, (Key, Value)),
        append([','],NewSub, SubListi),
        json_members(NewSub, SubList, MoreMembers),
        !.
json_members(List, SubList, [(Key, Value)]) :-
        json_pair(List, SubList, (Key,Value)).

%%%% json_elements/2 restituisce una lista di value.

json_elements(List, RestListOut, [Value | MoreElements]) :-
        delete_space(List, ListIn),
        json_value(ListIn, SubList, Value),
        delete_space(SubList, SubListi),
        append([','],NewSub, SubListi),
        json_elements(NewSub, RestList, MoreElements),
        delete_space(RestList, RestListOut),
        !.
json_elements(List, RestList, [Value]) :-
        delete_space(List,ListIn),
        json_value(ListIn, RestList, Value).

%%%% json_object/2 restituisce un oggetto contente dei members.

json_object(List,_,[]) :-
        delete_space(List, [GraphOut | More]),
        is_parengout(GraphOut),
        delete_space(More, []),
        !.
json_object(List, ListOut, ListMember) :-
        delete_space(List, ListIn),
        json_members(ListIn ,SubList, ListMember),
        append(['}'], SubLista,SubList),
        delete_space(SubLista, ListOut),
        !.

%%%% json_array/2 restituisce un array contente dei elements.

json_array(List,_,[]) :-
        delete_space(List, [GraphQOut | More]),
        is_parenq_out(GraphQOut),
        delete_space(More, []),
        !.
json_array(List,ListOut, ListMember) :-
        delete_space(List,ListIn),
        json_elements(ListIn ,SubList, ListMember),
        append([']'], SubLista,SubList),
        delete_space(SubLista, ListOut),
        !.

%%%% json/3 restiuisce un oggetto o un array a seconda dell'input

json(ListAtom,RestList, json_obj(JSON)) :-
        delete_space(ListAtom, [InAtom | AtomList]),
        is_parengin(InAtom),
        json_object(AtomList, RestList, JSON),
        !.
json(ListAtom, RestList, json_array(JSON)) :-
        delete_space(ListAtom, [InAtom | AtomList]),
        is_parenq_in(InAtom),
        json_array(AtomList,RestList, JSON).

%%%% json_parse/2 prende in unput una stringa json e restituisce un oggetto
%%%% se la stringa passata rispetta le specifiche

json_parse(JSONString , Object) :-
        atom_chars(JSONString, AtomList),
        json(AtomList, SubList, Object),
        is_empty(SubList, _).

%%%% json get/3 prende un oggetto in input e una variabile field
%%%% che può essere un numero, una stringa o una lista contente stringa / numero
%%%% in output restituisce il value ottenuto facendo ricorsivamente la get di ogni variabile.

json_get(Object, Field, Result) :-
        json_get_json(Object, Field, Result),
        !.
json_get(Object, Index, Result) :-
        number(Index),
        Object = json_array(List),
        json_get_array(List, Index, Result),
        !.
json_get(Object, Key, Result) :-
        string(Key),
        Object = json_obj(List),
        json_get_obj(List, Key, Result).

%%%%json_get_json/3

json_get_json(Obj, [Y], Result) :-
        number(Y),
        Obj = json_array(List),
        json_get_array(List, Y, Result),
        !.
json_get_json(Obj, [Y], Result) :-
        string(Y),
        Obj = json_obj(List),
        json_get_obj(List, Y, Result),
        !.
json_get_json(Obj, [Y | More], Output) :-
        string(Y),
        Obj = json_obj(List),
        json_get_obj(List, Y, Result),
        json_get(Result, More, Output),
        !.
json_get_json(Obj, [Y | More], Output) :-
        number(Y),
        Obj = json_array(List),
        json_get_array(List, Y, Result),
        json_get(Result, More, Output),
        !.

json_get_array(List, Index, Result) :-
        nth0(Index, List, Result).

json_get_obj([(Key,Val)], KeySearch, Val) :-
        Key = KeySearch,
        !.

json_get_obj([(Key,Val) | _], KeySearch, Val) :-
        Key = KeySearch,
        !.

json_get_obj([(_, _) | More], KeySearch, Result) :-
        json_get_obj(More, KeySearch, Result).

%%%% json_load/2 carica un json facendo la json_parse su quest'ultimo e
%%%% restituisce in output un oggetto json prolog

json_load(FileName, Object) :-
        open(FileName, read, In),
        read_stream_to_codes(In, ContenutoFile),
        close(In),
        atom_codes(JSONStr, ContenutoFile),
        json_parse(JSONStr, Object).

%%%% json_write/2 prende in input un oggetto json prolog, lo converte e
%%%% lo scrive in un file

json_write(Object, FileName) :-
        open(FileName, write, Out),
        json_write_json(Object, ListChars),
        atom_chars(Result, ListChars),
        write(Out, Result),
        close(Out).

json_write_json(Object, Result) :-
        Object = json_obj(List),
        json_write_members(List, Rest1),
        append(['{', ' '], Rest1, Rest2),
        append(Rest2, [' ', '}'], Result),
        !.

json_write_json(Object, Result) :-
        Object = json_array(List),
        json_write_elements(List, Rest1),
        append(['[', ' '], Rest1, Rest2),
        append(Rest2, [' ', ']'], Result),
        !.

json_write_members([], []) :-
        !.
json_write_members([(Key, Value)], Result) :-
        json_write_pair((Key, Value), Result),
        !.
json_write_members([(Key, Value) |More], Result) :-
        json_write_pair((Key, Value), OutPair),
        json_write_members(More, Rest),
        append(OutPair, [',',' '], OutPair2),
        append(OutPair2, Rest, Result),
        !.

json_write_elements([], []) :-
        !.
json_write_elements([Value], Result) :-
        json_write_value(Value, Result),
        !.
json_write_elements([Value | More], Result) :-
        json_write_value(Value, OutVal),
        json_write_elements(More, Rest),
        append(OutVal, [',', ' '], Out1),
        append(Out1, Rest, Result),
        !.

json_write_pair((Key,Value), Result) :-
        string_chars(Key, KeyChars1),
        append(['"'], KeyChars1, KeyChars2),
        append(KeyChars2, ['"'], KeyChars3),
        json_write_value(Value, Rest),
        append(KeyChars3, [' ', ':', ' '], Pair1),
        append(Pair1, Rest, Result),
        !.

json_write_value(Object, Result) :-
        json_write_json(Object, Result),
        !.

json_write_value(Number, Result) :-
        number(Number),
        number_chars(Number, Result),
        !.
json_write_value(String, Result) :-
        string_chars(String, StrChars1),
        append(['"'], StrChars1, StrChars2),
        append(StrChars2, ['"'], Result),
        !.

%%%% end of file -- lists.pl













