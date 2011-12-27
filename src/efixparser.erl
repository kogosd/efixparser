-module(efixparser).
-compile(export_all).
%-compile('hipe, [o3]').
-include_lib("xmerl/include/xmerl.hrl").


-define(TESTFIXMESSAGE, "8=FIX4.2\00135=D\00149=ABC\00156=DEF\00134=1234\00118=1\00121=2\00138=100\00144=22.5\00140=1\00159=3\00110=100\001").


start_() ->
	io:format("Will parse ~p~n", [?TESTFIXMESSAGE]),
	{Megaseconds0,Seconds0,Microseconds0} = erlang:now(),

	Count = 1000,
	times(Count, fun()-> Dict = [], parse(?TESTFIXMESSAGE, lookingforstart, Dict) end),

	{Megaseconds1,Seconds1,Microseconds1} = erlang:now(),
	io:format("It took ~p usec per run~n", [(Megaseconds1*1000000000000 - Megaseconds0*1000000000000 + Seconds1*1000000 - Seconds0*1000000 + Microseconds1 - Microseconds0)/Count]),
	void.


start() ->
	statsserver:start(),

	Count = 1000000,

	times(Count, fun()-> 
					{T,_} = 
						timer:tc ( 
							?MODULE, parse, [?TESTFIXMESSAGE, lookingforstart, []]
						),
					statsserver:add(fixtime, T)
	             end),

	io:format("Sync parsing: Median,P95,P98 =~p~n", [statsserver:median(fixtime)]),
	void.


times(0, F) ->
	void;

times(N, F) ->
	F(),
	times(N-1, F).
	

%
% parse/3
%
parse([], lookingforstart , Dict) ->
	print_parsed(Dict),
	void;

parse([$8|T], lookingforstart, Dict) ->
	parse(T, intag, $8, Dict);

parse([H|T], lookingforstart, Dict) ->
	parse(T, lookingforstart, Dict).



%
% parse/4
%
parse([], intag, _,  Dict) ->
	print_parsed(Dict),
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
	io:format("~p~n", [H]),
	print_parsed(T).	

