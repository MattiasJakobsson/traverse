defmodule TestStep do
  use Traverse.Workflow.Step

  def run_step(definition, _) do
    IO.puts definition["name"]

    Process.send_after(self(), :test, 1000)

    :started
  end

  def handle_info(:test, data) do
    done("asd", :next)
    {:noreply, data}
  end
end

defmodule TestCommand do
  use Traverse.Workflow.Command

  def execute(params) do
    IO.inspect params
    nil
  end
end

defmodule TestQuery do
  use Traverse.Workflow.Query

  def execute(params) do
    IO.inspect params
    params
  end
end
