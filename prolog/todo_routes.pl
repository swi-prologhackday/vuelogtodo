/** <module> Routing
* Here all routes are defined in order to avoid collisions.
*/
:- module(todo_routes, []).

:- use_module(todo_page, [todo_page_handler/1]).

:- http_handler(root(.), todo_page_handler, []).