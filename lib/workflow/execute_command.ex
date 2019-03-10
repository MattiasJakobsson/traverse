defmodule Traverse.Workflow.ExecuteCommand do
  use Traverse.Workflow.Step

  def run_step(definition, _) do
    {:ok, process} = GenServer.start_link(String.to_existing_atom("Elixir.#{definition.command}"), [])

    response = GenServer.call(process, {:execute, definition.params})
    
    {:next, response}
  end
end
