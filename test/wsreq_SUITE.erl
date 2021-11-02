-module(wsreq_SUITE).

-compile([export_all]).

-include_lib("common_test/include/ct.hrl").
-include("../src/websocket_req.hrl").

all() ->
    [
     t_websocket_req_set
    ].

suite() ->
    [{ct_hooks,[cth_surefire]}, {timetrap, {seconds, 30}}].


init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

t_websocket_req_set(_) ->
    CleanReq = #websocket_req{},
    Fields = record_info(fields, websocket_req),
    %% Call websocket_req:set([{Field, Value}], #websocket_req{})
    [ begin
          Req1 = websocket_req:set([{Field, new_value}], CleanReq),
          Req1 /= CleanReq orelse ct:fail({unchanged, Field})
      end
      || Field <- Fields ],
    ok.

