defmodule Traverse.Engine do
  use GenServer

  def find_all_available_step_types() do
    Traverse.Steps.Step.find_all_step_types()
  end
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  
  def schedule_workflow(triggers, definition) do
    {:ok, parsed_triggers} = Poison.Parser.parse(triggers)

    schedule(parsed_triggers, definition)
    
    :ok
  end

  defp schedule([head | _tail = []], definition) do
    schedule(head, definition)
  end

  defp schedule([head | tail], definition) do
    schedule(head, definition)

    schedule(tail, definition)
  end

  defp schedule(trigger, definition) do
    Traverse.Triggers.Trigger.start_trigger(trigger, definition)
  end

  def start_workflow(definition, initial_state) do
    {:ok, parsed_definition} = Poison.Parser.parse(definition)
    {:ok, parsed_state} = Poison.Parser.parse(initial_state)
    
    GenServer.cast(__MODULE__, {:start_workflow, {parsed_definition, parsed_state}})
  end

  def workflow_finished(workflow_id, state) do
    GenServer.cast(__MODULE__, {:execution_finished, {workflow_id, state}})
  end

  def init(workflows) do
    {:ok, workflows}
  end

  def handle_cast({:start_workflow, {definition, initial_state}}, workflows) do
    workflow_id = Traverse.Workflow.start_workflow(definition, initial_state)
    {:noreply, [workflow_id | workflows]}
  end

  def handle_cast({:execution_finished, {workflow_id, _state}}, workflows) do
    GenServer.stop({:global, workflow_id})
    {:noreply, List.delete(workflows, workflow_id)}
  end
end
