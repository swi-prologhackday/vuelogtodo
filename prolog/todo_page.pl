/** <module> Rendering
* Predicates for generating HTML, CSS, and Javascript.
*/
:- module(todo_page, [todo_page_handler/1]).

:- use_module(library(http/html_write)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(css_write), [css//1, write_css/2]).
:- use_module(vuelog, [vue_html//1,
                   vue_context//2,
                   op(_, _, in)]).
:- use_module(todo_common).


%! todo_page_handler(+Request) is semidet.
%  Handler for main meal plain page.
todo_page_handler(Request) :-
    memberchk(method(get), Request),
    init_state(State),
    reply_html_page(app,
        title('Vuelog Based Todo List'),
        \todo_page(State)).

include_css(CssDcg) -->
    { write_css(CssDcg, CssTxt) },
    html_post(head, style([], CssTxt)).

todo_page(State) -->
    vue_context(_{initial_state: State,
                  pengine_app_name: todo_app,
                  root_element_sel: "#app"},
                  div(id(app),
                     [div(class(todos),
                         [h2("To Do"),
                          \todo_list,
                          br([]),
                          \add_todo])])).

todo_list -->
    vue_html([vue_list(todo in todos,
                       li(class(todo),
                           [
                            input([type(checkbox), name(toggle)]),
                            $('todo.desc')
                           ])
                      )]).

add_todo -->
    vue_html(
        vue_form(submit(add_todo), [
            input([type(text), name(desc), required(true),
            placeholder('Enter ToDo')]),
            input([type(submit), value('Add')])
        ])
    ).