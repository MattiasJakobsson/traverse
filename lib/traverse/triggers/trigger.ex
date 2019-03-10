defmodule Traverse.Triggers.Trigger do
  @callback start(settings) :: :ok when settings: Any
  @callback stop(settings) :: :ok when settings: Any
  
  defmodule Definition do
    defstruct settings: %{},
              workflow: nil,
              trigger_id: nil
  end

  def start_trigger(settings, workflow) do
    definition = %Traverse.Triggers.Trigger.Definition{settings: settings, workflow: workflow, trigger_id: UUID.uuid4()}

    GenServer.start_link(
      String.to_existing_atom("Elixir.#{settings.triggerType}"),
      definition,
      name: {:global, definition.trigger_id}
    )

    {:ok, definition}
  end
  
  def stop_trigger(trigger_id) do
    GenServer.stop({:global, trigger_id})

    :ok
  end
  
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      @behaviour Traverse.Triggers.Trigger

      def init(definition) do
        start(definition.settings)
        
        {:ok, definition}
      end

      def handle_cast(:trigger, definition), do: handle_cast({:trigger, "{}"}, definition)
      
      def handle_cast({:trigger, initial_state}, definition) do
        Traverse.Engine.start_workflow(definition.workflow, initial_state)
        
        {:noreply, definition}
      end
      
      def terminate(_, definition), do: stop(definition)
    end
  end

  defmacro __before_compile__(env) do
    unless Module.defines?(env.module, {:start, 1}) do
      message = """
      function start/1 required by behaviour Trigger is not implemented \
            (in module #{inspect(env.module)}).
      We will inject a default implementation for now:
        def start(_settings), do: nil
      """

      :elixir_errors.warn(env.line, env.file, message)

      quote do
        def start(_settings), do: nil

        defoverridable start: 1
      end
    end

    unless Module.defines?(env.module, {:stop, 1}) do
      quote do
        def stop(_settings), do: nil

        defoverridable stop: 1
      end
    end
  end
end
