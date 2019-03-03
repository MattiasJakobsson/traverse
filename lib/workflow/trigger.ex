defmodule Traverse.Workflow.Trigger do
  @moduledoc false
  
  @callback start(settings) :: :ok when settings: Any
  @callback stop(settings) :: :ok when settings: Any

  def start_trigger(settings, workflow) do
    trigger_id = UUID.uuid4()

    GenServer.start_link(
      String.to_existing_atom("Elixir.#{settings["triggerType"]}"),
      {settings, workflow},
      name: {:global, trigger_id}
    )

    GenServer.cast({:global, trigger_id}, :start)

    {:ok, trigger_id}
  end
  
  def stop_trigger(trigger_id) do
    GenServer.cast({:global, trigger_id}, :stop)
    
    :ok
  end
  
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      @behaviour Traverse.Workflow.Trigger

      def init(data) do
        {:ok, data}
      end

      def handle_cast(:trigger, {settings, workflow}) do
        handle_cast({:trigger, "{}"}, {settings, workflow})
      end
      
      def handle_cast({:trigger, initial_state}, {settings, workflow}) do
        Traverse.Workflow.Engine.start_workflow(workflow, initial_state)
        
        {:noreply, {settings, workflow}}
      end
      
      def handle_cast(:start, {settings, workflow}) do
        start(settings)

        {:noreply, {settings, workflow}}
      end
      
      def handle_cast(:stop, {settings, workflow}) do
        stop(settings)
        
        {:noreply, {settings, workflow}}
      end
    end
  end

  defmacro __before_compile__(env) do
    unless Module.defines?(env.module, {:start, 1}) do
      message = """
      function start/1 required by behaviour Trigger is not implemented \
            (in module #{inspect(env.module)}).
      We will inject a default implementation for now:
        def start(_settings) do
          nil
        end
      """

      :elixir_errors.warn(env.line, env.file, message)

      quote do
        @doc false
        def start(_settings) do
          nil
        end

        defoverridable start: 1
      end
    end

    unless Module.defines?(env.module, {:stop, 1}) do
      message = """
      function stop/1 required by behaviour Trigger is not implemented \
                  (in module #{inspect(env.module)}).
      We will inject a default implementation for now:
        def stop(_settings) do
          nil
        end
      """

      :elixir_errors.warn(env.line, env.file, message)

      quote do
        @doc false
        def stop(_settings) do
          nil
        end

        defoverridable stop: 1
      end
    end
  end
end
