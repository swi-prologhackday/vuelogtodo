/** <module> Public API
* State manipulation for the meal planner. This module is exposed via pengines.
*/
:- module(todo_api, [handle_event/3]).

:- use_module(library(ordsets), [list_to_ord_set/2,
                                 ord_intersection/3,
                                 ord_union/3]).
:- use_module(library(list_util), [split/3,
                                   replicate/3,
                                   iterate/3]).
:- use_module(library(clpfd), [transpose/2]).

:- use_module(library(gensym)).

% State calculations

add_todo(NewTodo), [State1] -->
    [State0],
    { Todos = [NewTodo|State0.todos],
      State1 = State0.put(todos, Todos)}.

% Events

%! handle_event(+CurrentState:dict, +Event:atom, -NewState:dict) is det.
%  Given the current state and an event, calculate what the next state
%  will be.
%
%  @arg CurrentState Dictionary representing the current app state.
%  @arg Event An atom representing a state transation.
%  @arg NewState Dictionary representing the state that results from
%                 applying =Event= to =CurrentState=.

handle_event(State0,
             add_todo(js{desc: Desc}),
             State1) :-
    gensym('', Id),
    NewTodo = todo{desc: Desc, id: Id, complete: false},
    phrase(add_todo(NewTodo), [State0], [State1]), !.

handle_event(State, update, State) :-
    debug(pengine, "Updating state ~w", [State]).

handle_event(State, Event, State) :-
    debug(pengine, "Unknown Pengine event ~w ~w", [State, Event]).
