defmodule Traverse.Steps.ExecuteQuery do
  use Traverse.Steps.Step

  def run_step(definition, _) do
    {:ok, process} = GenServer.start_link(String.to_existing_atom("Elixir.#{definition.query}"), [])

    response = GenServer.call(process,  {:execute, definition.params})

    {:next, response}
  end
end
