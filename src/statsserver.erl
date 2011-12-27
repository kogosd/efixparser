-module(statsserver).
-compile(export_all).
-compile([native,{hipe, [o3]}]).
-behavior(gen_server).

%wrappers for server calls
start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
add(What, Data) ->gen_server:call(?MODULE, {add, What, Data}).
add(Data) ->gen_server:call(?MODULE, {add, Data}).
stats(What) -> gen_server:call(?MODULE, {stats, What}).
stats() -> gen_server:call(?MODULE, {stats}).

init([]) ->
	Datastore = dict:new(),
	Datalist  = [],
	{ok, {Datastore, Datalist}}.

handle_call({add, What, Data}, _From, {Datastore,Datalist}) ->
	Datastore2 = dict:append(What, Data, Datastore),
	{reply, ok, {Datastore2, Datalist}};

handle_call({add, Data}, _From, {Datastore,Datalist}) ->
	Datalist2 = [Data] ++ Datalist,
	{reply, ok, {Datastore, Datalist2}};
		
handle_call({stats, What}, _From, {Datastore, Datalist}) ->
	Stats = get_stats(What, Datastore),
	{reply, Stats , {Datastore, Datalist}};

handle_call({stats}, _From, {Datastore, Datalist}) ->
	Stats = get_stats(Datalist),
	{reply, Stats , {Datastore, Datalist}}.

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
	{Size, 
	 lists:nth(1, Currentdatasorted),
	 lists:nth(P50, Currentdatasorted),
	 lists:nth(P95, Currentdatasorted),
	 lists:nth(P98, Currentdatasorted),
	 lists:nth(Size, Currentdatasorted)
	 } .
	

