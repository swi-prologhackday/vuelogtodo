:- encoding(utf8).
/** <module> Things that are common both to page render and back end
 *
 * Note - init_state isn't yet, but might become so.
 *
 */
:- module(todo_common, [init_state/1]).

%! init_state(-NewState:dict) is det.
%  Create a fresh app state dict.
%
%  @arg NewState Dictionary representing the fresh app state.
init_state(state{
               items: []
           }).

