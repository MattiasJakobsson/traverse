defmodule Traverse.Steps.ExecuteCommand do
  use Traverse.Steps.Step

  def run_step(definition, state) do
    {:ok, process} = GenServer.start_link(String.to_existing_atom("Elixir.#{definition.command}"), [])

    {:ok, response} = GenServer.call(process, {:execute, Traverse.ParameterInterpreter.eval_code(definition.params, %{state: state})})
    
    {:next, response}
  end

  defmodule Command do
    @callback execute(params) :: %{} when params: %{} | nil

    defmacro __using__(opts) do
      quote location: :keep, bind_quoted: [opts: opts] do
        use GenServer
        @behaviour Traverse.Steps.ExecuteCommand.Command

        def init(data) do
          {:ok, data}
        end

        def handle_call({:execute, params}, _, data) do
          response = execute(params)

          {:reply, response, data}
        end

        defoverridable init: 1
      end
    end
  end
end
