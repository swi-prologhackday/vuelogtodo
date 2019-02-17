/** <module> Rendering
* Predicates for generating HTML, CSS, and Javascript.
*/
:- module(todo_page, []).

:- use_module(library(http/html_write)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(css_write), [css//1, write_css/2]).
:- use_module(vuelog, [vue_html//1,
                   vue_context//2,
                   op(_, _, in)]).
:- use_module(todo_common).

% Set up the back end
:- ensure_loaded(todo_api).
:- use_module(library(pengines)). % shows unused, but is needed

:- pengine_application(todo_app).
:- use_module(todo_app:todo_api).


:- http_handler(root(.), todo_page_handler, []).

%! meal_plan_handler(+Request) is semidet.
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
                div([id(app)],
                    [div(class('parameters'),
                         [label(["Start Date",
                                 vue_input([type(date), model(start_day)])]),
                          label(["End Date",
                                 vue_input([type(date), model(end_day)])]),
                          label(["Meals per day",
                                 % XXX: some way to indicate that
                                 % meals_per_day should be treated as
                                 % a number?
                                 vue_input([type(number), model(meals_per_day)])])]),
                     div(class(meals), \meals),
                     div(class(schedule),
                         [h2("Schedule"),
                          vue_button(click(rerun), "New Schedule"),
                          \calendar])])).

meals -->
    vue_html([h2("Menu Options"),
              ul(vue_list(meal in meals,
                     li([class(meal)],
                        [$('meal.name'),
                         br([]),
                         p(['Makes a meal for ', $('meal.days'), ' days']),
                         br([]),
                         vue_list(tag in 'meal.tags',
                                  span([], [$(tag), &(nbsp)]))]))),
              \add_meal]).


add_meal -->
    vue_html(vue_form(submit(add_meal),
                      [input([type(text), name(name), required(true),
                              placeholder('Food name')]),
                       input([type(text), name(tags), required(true),
                              placeholder('Comma-separated tags')]),
                       input([type(number), name(days), required(true), min(1),
                              placeholder('How many days will this last?')]),
                       input([type(submit), value('Add')])])).

calendar_css -->
    css(['.calendar'(
             [display(flex), 'flex-direction'(row)],
             '.day'([margin('0.5em')],
                    '.meal-slot'(['min-height'('2em'),
                                  margin('0.5em'),
                                  'text-align'(center),
                                  'background-color'(darkgreen),
                                  color(white)])))]).

calendar -->
    vue_html([\include_css(calendar_css),
              div(class(calendar),
                  vue_list(slot in slots,
                           div(class(day),
                               [$('slot.day'), \slots('slot.entries')])))
             ]).

slots(Entries) -->
    vue_html(vue_list(entry in Entries,
                      div(class('meal-slot'),
                          $('entry.name')))).
