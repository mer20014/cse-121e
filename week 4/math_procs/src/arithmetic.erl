-module(arithmetic).
-export([start_factorializer/0,start_adder/0,start_subtracter/0,start_multiplier/0,start_divider/0,
		 factorializer/0,adder/0,subtracter/0,multiplier/0,divider/0,
		 factorial_of/2,add/3,subtract/3,multiply/3,divide/3]).

start_factorializer() ->
	spawn(?MODULE,factorializer,[]).

start_adder() ->
	spawn(?MODULE,adder,[]).

start_subtracter() ->
	spawn(?MODULE, subtracter, []).

start_multiplier() ->
	spawn(?MODULE, multiplier, []).

start_divider() ->
	spawn(?MODULE, divider, []).

factorial_of(Factor_pid, Number) ->
	Factor_pid ! {self(), Number},
	receive
		Response ->
			Response
	end.

add(Add_pid, First_number, Second_number) ->
	Add_pid ! {self(), First_number, Second_number},
	receive
		Response ->
			Response
	end.
subtract(Subtract_pid, First_number, Second_number) ->
	Subtract_pid ! {self(), First_number, Second_number},
	receive
		Response ->
			Response
	end.

multiply(Multiply_pid, First_number, Second_number) ->
	Multiply_pid ! {self(), First_number, Second_number},
	receive
		Response ->
			Response
	end.
divide(Divide_pid, First_number, Second_number) ->
	Divide_pid ! {self(), First_number, Second_number},
	receive
		Response ->
			Response
	end.	

factorializer() ->
	receive
		{Pid, Numbers} when is_integer(Numbers) == false ->
			Pid ! {fail, Numbers, is_not_integer};
		{Pid, Numbers} when Numbers < 0 ->
			Pid ! {fail, Numbers, is_negative};
		{Pid, Numbers} -> 
			Pid ! lists:foldl(fun(X, Accum) -> X * Accum end, 1, lists:seq(1, Numbers))
	end,
	factorializer().

adder() ->
	receive
		{Pid, First_number, _Second_number} when is_number(First_number) == false ->
			Pid ! {fail, First_number, is_not_number};
		{Pid, _First_number, Second_number} when is_number(Second_number) == false ->
			Pid ! {fail, Second_number, is_not_number};
		{Pid, First_number, Second_number} ->
			Pid ! First_number + Second_number
	end,
	adder().

subtracter() ->
	receive
		{Pid, First_number, _Second_number} when is_number(First_number) == false ->
			Pid ! {fail, First_number, is_not_number};
		{Pid, _First_number, Second_number} when is_number(Second_number) == false ->
			Pid ! {fail, Second_number, is_not_number};
		{Pid, First_number, Second_number} ->
			Pid ! First_number - Second_number
	end,
	subtracter().

multiplier() ->
	receive
		{Pid, First_number, _Second_number} when is_number(First_number) == false ->
			Pid ! {fail, First_number, is_not_number};
		{Pid, _First_number, Second_number} when is_number(Second_number) == false ->
			Pid ! {fail, Second_number, is_not_number};
		{Pid, First_number, Second_number} ->
			Pid ! First_number * Second_number
	end,
	multiplier().

divider() ->
	receive
		{Pid, First_number, _Second_number} when is_number(First_number) == false ->
			Pid ! {fail, First_number, is_not_number};
		{Pid, _First_number, Second_number} when is_number(Second_number) == false ->
			Pid ! {fail, Second_number, is_not_number};
		{Pid, First_number, Second_number} ->
			Pid ! First_number / Second_number
	end,
	divider().
	
	
-ifdef(EUNIT).
%%
%% Unit tests go here. 
%%

-include_lib("eunit/include/eunit.hrl").


factorializer_test_() ->
{setup, 
	fun() -> % runs before any of the tests
			Pid = spawn(?MODULE, factorializer, []), 	
			register(test_factorializer, Pid)
		end, 
	% fun(_)-> % runs after all of the tests
		% there is no teardown needed, so this fun doesn't need to be implemented.
	% end, 
	% factorializer tests start here
	[ ?_assertEqual(120,  factorial_of(test_factorializer,  5)),  % happy path, tests the obvious case.
	  % test less obvious or edge cases
	  ?_assertEqual(1, factorial_of(test_factorializer, 0)), 
	  ?_assertEqual({fail, -3, is_negative}, factorial_of(test_factorializer, -3)), 
	  ?_assertEqual({fail, bob, is_not_integer}, factorial_of(test_factorializer, bob)), 
	  ?_assertEqual({fail, 5.0, is_not_integer}, factorial_of(test_factorializer, 5.0))
	]
}.

adder_test_() ->
{setup, 
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE, adder, []), 	
			register(test_adder, Pid)
		end, 
	%fun(_)->%runs after all of the tests
		%there is no teardown needed, so this fun doesn't need to be implemented.
	%end, 
	%factorializer tests start here
	[ ?_assertEqual(8, add(test_adder, 5, 3)), %happy path
	  % test less obvious or edge cases
	  ?_assertEqual(0, add(test_adder, 0, 0)), 
	  ?_assertEqual(0.0, add(test_adder, 0.0, 0.0)), 
	  ?_assertEqual(0, add(test_adder, -5, 5)), 
	  ?_assertEqual(1.5, add(test_adder, 0.75, 0.75)), 
	  ?_assertEqual({fail, bob, is_not_number}, add(test_adder, bob, 3)), 
	  ?_assertEqual({fail, sue, is_not_number}, add(test_adder, 3, sue)), 
	  ?_assertEqual({fail, bob, is_not_number}, add(test_adder, bob, sue))
	]
}.

subtracter_test_() ->
{setup, 
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE, subtracter, []), 	
			register(test_subtracter, Pid)
		end, 
	%fun(_)->%runs after all of the tests
		%there is no teardown needed, so this fun doesn't need to be implemented.
	%end, 
	%factorializer tests start here
	[ ?_assertEqual(2, subtract(test_subtracter, 5, 3)), %happy path
	  % test less obvious or edge cases
	  ?_assertEqual(0, subtract(test_subtracter, 0, 0)), 
	  ?_assertEqual(0.0, subtract(test_subtracter, 0.0, 0.0)), 
	  ?_assertEqual(-10, subtract(test_subtracter, -5, 5)), 
	  ?_assertEqual(0.75, subtract(test_subtracter, 1.5, 0.75)), 
	  ?_assertEqual({fail, bob, is_not_number}, subtract(test_subtracter, bob, 3)), 
	  ?_assertEqual({fail, sue, is_not_number}, subtract(test_subtracter, 3, sue)), 
	  ?_assertEqual({fail, bob, is_not_number}, subtract(test_subtracter, bob, sue))
	]
}.

multiplier_test_() ->
{setup, 
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE, multiplier, []), 	
			register(test_multiplier, Pid)
		end, 
	%fun(_)->%runs after all of the tests
		%there is no teardown needed, so this fun doesn't need to be implemented.
	%end, 
	%factorializer tests start here
	[ ?_assertEqual(15, multiply(test_multiplier, 5, 3)), %happy path
	  % test less obvious or edge cases
	  ?_assertEqual(0, multiply(test_multiplier, 0, 0)), 
	  ?_assertEqual(0.0, multiply(test_multiplier, 0.0, 0.0)), 
	  ?_assertEqual(-25, multiply(test_multiplier, -5, 5)), 
	  ?_assertEqual(1.125, multiply(test_multiplier, 1.5, 0.75)), 
	  ?_assertEqual({fail, bob, is_not_number}, multiply(test_multiplier, bob, 3)), 
	  ?_assertEqual({fail, sue, is_not_number}, multiply(test_multiplier, 3, sue)), 
	  ?_assertEqual({fail, bob, is_not_number}, multiply(test_multiplier, bob, sue))
	]
}.

divider_test_() ->
{setup, 
	fun()->%runs before any of the tests
			Pid = spawn(?MODULE, divider, []), 	
			register(test_divider, Pid)
		end, 
	%fun(_)->%runs after all of the tests
		%there is no teardown needed, so this fun doesn't need to be implemented.
	%end, 
	%factorializer tests start here
	[ ?_assert((1.6 < divide(test_divider, 5, 3)) and (divide(test_divider, 5, 3) < 1.7)), %happy path
	  % test less obvious or edge cases
	  ?_assertEqual(-1.0, divide(test_divider, -5, 5)), 
	  ?_assertEqual(2.0, divide(test_divider, 1.5, 0.75)), 
	  ?_assertEqual({fail, bob, is_not_number}, divide(test_divider, bob, 3)), 
	  ?_assertEqual({fail, sue, is_not_number}, divide(test_divider, 3, sue)), 
	  ?_assertEqual({fail, bob, is_not_number}, divide(test_divider, bob, sue))
	]
}.

-endif.