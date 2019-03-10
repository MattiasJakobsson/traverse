defmodule Traverse.Workflow.Command do
  @callback execute(params) :: Any when params: Any

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use GenServer
      @behaviour Traverse.Workflow.Command

      def init(data) do
        {:ok, data}
      end

      def handle_call({:execute, params}, _from, {workflow_id, step_id, definition, state}) do
        response = execute(Traverse.ParameterInterpreter.eval_code(params, %{state: state}))
        
        {:reply, response, {workflow_id, step_id, definition, state}}
      end

      defoverridable init: 1
    end
  end

  defmacro __before_compile__(env) do
    unless Module.defines?(env.module, {:execute, 1}) do
      message = """
      function execute/1 required by behaviour Command is not implemented \
      (in module #{inspect(env.module)}).
      We will inject a default implementation for now:
        def execute(params) do
          nil
        end
      """

      :elixir_errors.warn(env.line, env.file, message)

      quote do
        def execute(params) do
          nil
        end

        defoverridable execute: 1
      end
    end
  end
end
