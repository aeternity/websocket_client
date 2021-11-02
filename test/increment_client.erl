-module(increment_client).

-behaviour(websocket_client).

-export([
         start_link/1,
         stop/1
        ]).
-export([
         init/1,
         onconnect/2,
         ondisconnect/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).

-record(state, {
          waiting = undefined :: undefined | pid()
         }).

start_link(Url) ->
    {ok, _} = websocket_client:start_link(Url, ?MODULE, [self()]).

stop(Pid) ->
    Pid ! stop.

init([Waiting]) ->
    {once, #state{waiting=Waiting}}.

onconnect(_WSReq, State) ->
    State#state.waiting ! {ok, self()},
    self() ! {send, {binary, <<"1">>}},
    {ok, State}.

ondisconnect(Reason, State) ->
    {close, Reason, State}.

websocket_handle({binary, <<"10">>}, _, State) ->
    State#state.waiting ! {done, self()},
    % TODO Send something via message to State#state.waiting
    {ok, State};
websocket_handle({binary, NBin}, _, State) ->
    %% TODO Add when clause ensuring only integers < 10 are used?
    N = binary_to_integer(NBin),
    Reply = {binary, integer_to_binary(N + 1)},
    {reply, Reply, State};
websocket_handle(_, _, State) ->
    {ok, State}.

websocket_info({send, Payload}, _, State) ->
    {reply, Payload, State};
websocket_info(stop, _, State) ->
    {close, <<>>, State}.

websocket_terminate(_, _, _) ->
    ok.
