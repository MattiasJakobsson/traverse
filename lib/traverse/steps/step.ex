defmodule Traverse.Steps.Step do
  @callback run_step(definition, state) :: :started | :next | nil | {next_step, step_state} when definition: %{}, state: %{}, step_state: %{} | nil, next_step: %{} | :next | nil

  defmodule Definition do
    defstruct workflow_id: nil,
              step_id: nil,
              step_definition: %{},
              state: %{},
              parent: nil
  end

  def start_step(workflow_id, definition, state, parent \\ self()) do
    step_id = UUID.uuid4()

    GenServer.start_link(
      String.to_existing_atom("Elixir.#{definition.stepType}"),
      %Definition{workflow_id: workflow_id, step_id: step_id, step_definition: definition, state: state, parent: parent},
      name: {:global, step_id}
    )

    {:ok, step_id}
  end

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      import Traverse.Steps.Step
      
      @behaviour Traverse.Steps.Step

      def init(definition) do
        GenServer.cast(self(), :execute)
        
        {:ok, definition}
      end

      def handle_cast(:execute, definition) do
        case run_step(definition.step_definition, definition.state) do
          :started -> nil
          response -> done(response)
        end
        
        {:noreply, definition}
      end

      def handle_cast({:done, :next}, definition), do: handle_cast({:done, {:next, nil}}, definition)

      def handle_cast({:done, {:next, step_state}}, definition) do
        handle_cast({:done, {Map.get(definition.step_definition, :next), step_state}}, definition)
      end
      
      def handle_cast({:done, next_step, step_state}, definition) do
        GenServer.cast(definition, {:step_done, {definition.step_id, step_state, next_step}})

        {:noreply, definition}
      end
      
      def done(), do: done(:next)
      def done(nil), do: done({nil, nil})
      def done(options) when options: :next or {:next, %{}} or {nil, %{}} or {%{}, nil} or {%{}, %{}} or {nil, nil} do
        GenServer.cast(self(), {:done, options})
      end
    end
  end
end
