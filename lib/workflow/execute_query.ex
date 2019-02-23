defmodule Traverse.Workflow.ExecuteQuery do
  use Traverse.Workflow.Step

  def run_step(definition, _) do
    {:ok, process} = GenServer.start_link(String.to_existing_atom("Elixir.#{definition["query"]}"), [])

    response = GenServer.call(process,  {:execute, definition["params"]})

    {:next, response}
  end
end
