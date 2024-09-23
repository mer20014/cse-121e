-module(friend_tracker).
-export([start/1,rpc/2,run/1]).


%%
%% Spawn a process for adding, removing, and finding friends.
%% The parameter is an initial list of friends. It may be an 
%% empty list.
%%

start(Initial_friends_list)->
	spawn(?MODULE, run, [Initial_friends_list]). % The MODULE macro is used instead of hard coding the module name.


%%--------------------------
%% Client functions
%%--------------------------

%%
%% Add, remove, or find a friend.
%%
rpc(Pid,Message)->
	Pid ! {self(),Message},
	receive
         Response ->
             Response
     end.


%%---------------------------
%% Server function
%%---------------------------

run(Friend_list) ->
	% TODO: complete this function.
	Updated_friend_list = receive 
			{Pid, {add, Friend}} ->
				Pid ! received, 
				[Friend | Friend_list];
			{Pid, {has_friends, Users}} when is_list(Users) ->
				Pid ! length(Friend_list -- Users) == length(Friend_list) - length(Users),
				Friend_list;
			{Pid, {has_friend, User}} ->
				Pid ! lists:member(User, Friend_list),
				Friend_list;
			{Pid, {remove, Friend}} ->
				Pid ! received,
				Friend_list -- [Friend];
			{Pid, get} ->
				Pid ! Friend_list,
				Friend_list;
			{Pid, _Other} ->
				Pid ! {fail, unrecognized_message},
				Friend_list
		end,
	run(Updated_friend_list).

	

-ifdef(EUNIT).
%%
%% Unit tests go here. 
%%

-include_lib("eunit/include/eunit.hrl").


add_friend_test_() ->
{setup,
	fun()-> % runs before any of the tests to set up the test
			Pid = spawn(?MODULE, run, [[sue,grace,fred]]),	
			register(test_adder, Pid)
		end,
	fun(_)-> % runs after all of the tests to clean up from the test
		unregister(test_adder)
	end,

	% add_friend tests start here
	[ ?_assertEqual(received, rpc(test_adder, {add, bob})), % Test obvious case
	  % Test edge cases or less obvious cases
	  ?_assertEqual(received, rpc(test_adder, {add, 1})), % Yes, we can add a number to the list
	  ?_assertEqual(received, rpc(test_adder, {add, #{name=>suzannah, age=>23}})) % Yes we can add a map/dictionary to the list
	]
}.

add_friends_test_() ->
{setup,
	fun()-> %runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_adder,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_adder)
	end,
	% add_friends tests start here
	[ ?_assertEqual(received,rpc(test_adder,{add,[bob,alice,joe]})),%happy path
	  %nasty thoughts start here
	  ?_assertEqual(received,rpc(test_adder,{add,[]})),
	  ?_assertEqual(received,rpc(test_adder,{add,[#{name=>suzannah,age=>23},#{name=>gunhild,age=>20}]}))
	]
}.

has_friend_test_() ->
{setup,
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_finder,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_finder)
	end,
	% has_friend tests start here
	[ ?_assert(rpc(test_finder,{has_friend,sue})),%happy path. Should return true
	  %nasty thoughts start here
	  ?_assertNot(rpc(test_finder,{has_friend,bob})),
	  ?_assertNot(rpc(test_finder,{has_friend,[#{name=>suzannah,age=>23},#{name=>gunhild,age=>20}]}))
	]
}.

has_friends_test_() ->
{setup,
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_finder,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_finder)
	end,
	% has_friends tests start here
	[ ?_assert(rpc(test_finder,{has_friends,[sue,fred]})),%happy path, should return true
	  %nasty thoughts start here
	  ?_assert(rpc(test_finder,{has_friends,[]})),
	  ?_assertNot(rpc(test_finder,{has_friends,[bob]})),
	  ?_assertNot(rpc(test_finder,{has_friends,[#{name=>suzannah,age=>23},#{name=>gunhild,age=>20}]}))
	]
}.



remove_friend_test_() ->
{setup,
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_remover,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_remover)
	end,
	% remove friend tests start here
	[ ?_assertEqual(received,rpc(test_remover,{remove,fred})),%happy path
	  %nasty thoughts start here
	  ?_assertEqual(received,rpc(test_remover,{remove,bob})),
	  ?_assertEqual(received,rpc(test_remover,{remove,[#{name=>suzannah,age=>23},#{name=>gunhild,age=>20}]}))
	]
}.

remove_friends_test_() ->
{setup,
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_remover,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_remover)
	end,
	% remove friends tests start here
	[ ?_assertEqual(received,rpc(test_remover,{remove,[sue,fred]})),%happy path
	  %nasty thoughts start here
	  ?_assertEqual(received,rpc(test_remover,{remove,[bob]})),
	  ?_assertEqual(received,rpc(test_remover,{remove,[#{name=>suzannah,age=>23},#{name=>gunhild,age=>20}]}))
	]
}.

get_friends_test_() ->
{setup,
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_remover,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_remover)
	end,
	% get friends tests start here
	[ ?_assertEqual([sue,grace,fred],rpc(test_remover,get))%happy path
	]
}.

bad_message_test_() ->
	{setup,
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE,run,[[sue,grace,fred]]),	
			register(test_bad_message,Pid)
		end,
	fun(_)->%runs after all of the tests
		unregister(test_bad_message)
	end,
	% bad message tests start here
	[ ?_assertMatch({fail, unrecognized_message},rpc(test_bad_message,what)),%happy path
	  ?_assertMatch({fail, unrecognized_message},rpc(test_bad_message,nil)),
	  ?_assertMatch({fail, unrecognized_message},rpc(test_bad_message,[])),
	  ?_assertMatch({fail, unrecognized_message},rpc(test_bad_message,{}))
	]
}.

-endif.