-module(statsserver).
-compile(export_all).
-behavior(gen_server).
-include_lib("xmerl/include/xmerl.hrl").

%wrappers for server calls
start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
add(What, Data) ->gen_server:call(?MODULE, {add, What, Data}).
stats(What) -> gen_server:call(?MODULE, {stats, What}).

init([]) ->
	Datastore = dict:new(),
	{ok, Datastore}.

handle_call({add, What, Data}, _From, Datastore) ->

	case  dict:is_key(What, Datastore) of
		true ->
			Currentdata = dict:fetch(What, Datastore),
			Datastore1 = dict:append(What, Data, Datastore),
			{reply, ok, Datastore1};
		false ->
			Datastore2 = dict:append(What, [Data], Datastore),
			{reply, ok, Datastore2}
	end;
	
handle_call({stats, What}, _From, Datastore) ->
	Stats = get_stats(What, Datastore),
	{reply, Stats , Datastore}.

%
% get_stats/2
%
get_stats(What, Datastore) ->
	Currentdata = dict:fetch(What, Datastore),
	get_stats(Currentdata).	
	
%
% get_stats/1
%

get_stats([]) ->
	void;

get_stats(Currentdata)	->
	Currentdatasorted = lists:sort(Currentdata),
	Size = length(Currentdata),
	P50 = round(Size/2),
	P95 = round(Size*0.95),
	P98 = round(Size*0.98),
	{lists:nth(P50, Currentdatasorted),lists:nth(P95, Currentdatasorted),lists:nth(P98, Currentdatasorted)} .
	

