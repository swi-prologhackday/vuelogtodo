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
