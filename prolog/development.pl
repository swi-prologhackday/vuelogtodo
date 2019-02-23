:- encoding(utf8).
/** <module> Example todo list server
* Demo of the Vue/Pengine integration
*/
:- module(development, [go/1]).

% dev note - I'm deliberately doing this 'my way' even
% though I'm hacking up James' code, because I want to
% see if the system stays 'comfy' even if we're living
% in somebody else's preferences.
% Here, I tend to just import entire libs.
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_session)).
:- use_module(library(http/html_write)).

:- use_module(library(http/websocket)).
:- use_module(library(http/hub)).

% Set up the back end
:- ensure_loaded(todo_api).
:- use_module(library(pengines)). % shows unused, but is needed

:- pengine_application(todo_app).
:- use_module(todo_app:todo_api).

%! go(+Port) is det.
%  Main entry point to start the server.
%
%  @arg Port Integer port number to start the server on.
go(Port) :-
    create_browsers_room,
    http_set_session_options([]),
    http_server(http_dispatch, [port(Port)]).

% Routes
:- use_module(todo_routes).

:- multifile user:body//2.
user:body(app, Body) -->
    html(body([Body,
               script(src('https://cdn.jsdelivr.net/npm/vue/dist/vue.js'), []),
               script(src('https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js'), []),
               script(src('/pengine/pengines.js'), []),
               \html_receive(js)])).


% TODO move this liveserver stuff to another file once validated

:- http_handler(root(liveserver),
    http_upgrade_to_websocket(
        accept_browser,
        [ guarded(false),
            subprotocols([echo])
        ]),
    [ id(liveserver_websocket)
]).
    

%%	accept_browser(+WebSocket) is det.
%
%	Normally,  the  goal  called    by   http_upgrade_to_websocket/3
%	processes all communication with the   websocket in a read/write
%	loop. In this case however,  we tell http_upgrade_to_websocket/3
%	that we will take responsibility for   the websocket and we hand
%	it to the browsers room.
%
%	browsers_hub_room is the name of the listening browsers room

accept_browser(WebSocket) :-
	hub_add(browsers_hub_room, WebSocket, _Id).

%%	create_browsers_room
%
%	Where all the connections to the listening browsers will be handled.

create_browsers_room :-
    % TODO create make hook and other possible hooks
	hub_create(browsers_hub_room, Room, _{}),
	thread_create(liveserver_loop(Room, _HookNotification), _, []).


%%	liveserver_loop(+Room)
%
%	Realise the liveserver main loop: 
%   When make is called broadcast message in the browsers room

liveserver_loop(Room, HookNotification) :-
	% TODO handle notification of make hook
    broadcast_message(Room, HookNotification),
	liveserver_loop(Room, HookNotification).

%%	broadcast_message(+Room, +Hook)
%
%	broadcast message to the room for the given hook notification

broadcast_message(Room, _HookNotification) :-
    % TODO transform from hook notification to the message that
    % will be sent through the socket
    hub_broadcast(Room.name, _Message).

