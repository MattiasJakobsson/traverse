defmodule Traverse.Steps.Step do
  @callback run_step(definition, state) :: :started | nil | {definition, state} when definition: Any, state: Any

  def find_all_step_types() do
    available_modules(Traverse.Steps.Step) |> Enum.reduce([], &load_step/2)
  end

  def start_step(workflow_id, definition, state) do
    step_id = UUID.uuid4()

    GenServer.start_link(
      String.to_existing_atom("Elixir.#{definition.stepType}"),
      {workflow_id, step_id, definition, state},
      name: {:global, step_id}
    )

    GenServer.cast({:global, step_id}, :execute)

    {:ok, step_id}
  end

  defp load_step(module, modules) do
    if Code.ensure_loaded?(module), do: [module | modules], else: modules
  end

  defp available_modules(plugin_type) do
    Mix.Task.run("loadpaths", [])

    Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && plugin_type in behaviours end)
    |> Enum.uniq
    |> Enum.map(fn {module, _} -> module end)
  end

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      @behaviour Traverse.Steps.Step

      def init(data) do
        {:ok, data}
      end

      def handle_cast(:execute, {workflow_id, step_id, definition, state}) do
        run_step(definition, state) |> handle_step_started()
        {:noreply, {workflow_id, step_id, definition, state}}
      end

      def handle_cast({:step_done, step_state, :next}, {workflow_id, step_id, definition, state}) do
        Traverse.Workflow.step_finished(workflow_id, definition, step_id, step_state, Map.get(definition, :next))

        {:noreply, {workflow_id, step_id, definition, state}}
      end

      def handle_cast({:step_done, step_state, next_step}, {workflow_id, step_id, definition, state}) do
        Traverse.Workflow.step_finished(workflow_id, definition, step_id, step_state, next_step)

        {:noreply, {workflow_id, step_id, definition, state}}
      end

      def handle_step_started(:started) do
        nil
      end

      def handle_step_started(:next) do
        done(:next)
      end

      def handle_step_started({:next, step_state}) do
        done(step_state, :next)
      end

      def handle_step_started({next_step, step_state}) do
        done(step_state, next_step)
      end

      def handle_step_started(step_state) do
        done(step_state)
      end

      def done() do
        done(nil)
      end

      def done(:next) do
        done(nil, :next)
      end

      def done(step_state) do
        done(step_state, nil)
      end

      def done(step_state, :next) do
        GenServer.cast(self(), {:step_done, step_state, :next})
      end

      def done(step_state, next_step) do
        GenServer.cast(self(), {:step_done, step_state, next_step})
      end
    end
  end

  defmacro __before_compile__(env) do
    unless Module.defines?(env.module, {:run_step, 2}) do
      message = """
      function run_step/2 required by behaviour Step is not implemented \
      (in module #{inspect(env.module)}).
      We will inject a default implementation for now:
        def run_step(definition, state) do
          nil
        end
      """

      :elixir_errors.warn(env.line, env.file, message)

      quote do
        def run_step(definition, state) do
          nil
        end

        defoverridable run_step: 2
      end
    end
  end
end
