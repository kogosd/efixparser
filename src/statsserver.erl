-module(statsserver).
-compile(export_all).
-behavior(gen_server).
-include_lib("xmerl/include/xmerl.hrl").

%wrappers for server calls
start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
add(What, Data) ->gen_server:call(?MODULE, {add, What, Data}).
median(What) -> gen_server:call(?MODULE, {median, What}).

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
	
handle_call({median, What}, _From, Datastore) ->
	Median = get_median(What, Datastore),
	{reply, Median , Datastore}.

%
% get_median/2
%
get_median(What, Datastore) ->
	Currentdata = dict:fetch(What, Datastore),
	get_median(Currentdata).	
	
%
% get_median/1
%

get_median([]) ->
	void;

get_median(Currentdata)	->
	Currentdatasorted = lists:sort(Currentdata),
	Size = length(Currentdata),
	P50 = round(Size/2),
	P95 = round(Size*0.95),
	P98 = round(Size*0.98),
	{lists:nth(P50, Currentdatasorted),lists:nth(P95, Currentdatasorted),lists:nth(P98, Currentdatasorted)} .
	

