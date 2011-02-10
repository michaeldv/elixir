-module(elixir_module_methods).
-export([get_visibility/1, set_visibility/2, alias_local/5]).
-include("elixir.hrl").


set_visibility(#elixir_object{name=Name, data=Data}, Visibility) when is_atom(Data) ->
  MethodTable = ?ELIXIR_ATOM_CONCAT([mex_, Name]),
  ets:insert(MethodTable, { visibility, Visibility });

set_visibility(Self, Visibility) ->
  elixir_errors:raise(badarg, "cannot change visibility of defined object").

get_visibility(#elixir_object{name=Name, data=Data}) when is_atom(Data) ->
  MethodTable = ?ELIXIR_ATOM_CONCAT([mex_, Name]),
  ets:lookup_element(MethodTable, visibility, 2);

get_visibility(Self) ->
  [].

alias_local(#elixir_object{name=Name, data=Data} = Self, Filename, Old, New, ElixirArity) when is_atom(Data) ->
  Arity = ElixirArity + 1,
  MethodTable = ?ELIXIR_ATOM_CONCAT([mex_, Name]),
  case ets:lookup(MethodTable, { Old, Arity }) of
    [{{Old, Arity}, Line, Clauses}] ->
      elixir_object:store_wrapped_method(Name, Filename, {function, Line, New, Arity, Clauses});
    [] ->
      elixir_errors:raise(nomethod, "No local method ~s/~w in ~s", [Old, Arity, Name])
  end;

alias_local(_, _, _, _, _) ->
  elixir_errors:raise(badarg, "cannot alias local method outside object definition scope").