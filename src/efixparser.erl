-module(efixparser).
-compile(export_all).
-compile([native,{hipe, [o3]}]).


-define(TESTFIXMESSAGE, "8=FIX4.2\00135=D\00149=ABC\00156=DEF\00134=1234\00118=1\00121=2\00138=100\00144=22.5\00140=1\00159=3\00110=100\001").


start() ->
	statsserver:start(),

	Count = 500000,

	times(Count, 
		fun()-> 
			{T,_} = 
			timer:tc ( 
				?MODULE, parse, [?TESTFIXMESSAGE, lookingforstart, []]
			),
			statsserver:add(T)
	    end),

	io:format("Sync parsing: Median,P95,P98 =~p~n", [statsserver:stats()]),
	void.


times(0, F) ->
	void;

times(N, F) ->
	%io:format("~p~n", [N]),
	F(),
	times(N-1, F).
	

%
% parse/3
%
parse([], lookingforstart , Dict) ->
	void;

parse([$8|T], lookingforstart, Dict) ->
	parse(T, intag, $8, Dict);

parse([H|T], lookingforstart, Dict) ->
	parse(T, lookingforstart, Dict).



%
% parse/4
%
parse([], intag, _,  Dict) ->
	%print_parsed(Dict),
	void;

parse([$=|T], intag, Tag, Dict) ->
	parse(T, invalue, Tag, [], Dict);

parse([H|T], intag, Tag,  Dict) ->
	parse(T, intag,  Tag ++ [H], Dict).


%
% parse/5
%
parse([1|T], invalue, Tag, Value, Dict) ->
	Dict1 = [{Tag, Value}] ++ Dict,
	parse(T, intag, [], Dict1);
	
parse([H|T], invalue, Tag, Value, Dict) ->
	parse(T, invalue, Tag, Value ++ [H] , Dict).



%
% print_parsed/2
%
print_parsed([]) ->
	void;

print_parsed([H|T]) ->
	%io:format("~p~n", [H]),
	print_parsed(T).	


