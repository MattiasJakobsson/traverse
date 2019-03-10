defmodule Traverse.Workflow.Workflow do
  use GenServer

  def start_workflow(definition, initial_state) do
    workflow_id = UUID.uuid4()

    {:ok, _} = GenServer.start_link(
      __MODULE__,
      {definition, initial_state, workflow_id},
      name: { :global, workflow_id }
    )

    GenServer.cast({:global, workflow_id}, :start)

    workflow_id
  end

  def step_finished(workflow_id, step_definition, step_id, state, next_step) do
    GenServer.cast({:global, workflow_id}, {:step_done, step_definition, step_id, state, next_step})
  end

  def init(data) do
    {:ok, data}
  end

  def handle_cast(:start, {definition, state, workflow_id}) do
    execute_next_step(workflow_id, definition, state)

    {:noreply, {definition, state, workflow_id}}
  end

  def handle_cast({:step_done, step_definition, step_id, step_state, nil}, {definition, state, workflow_id}) do
    GenServer.stop({:global, step_id})

    new_state = Map.put(state, step_definition.id, step_state)

    Traverse.Workflow.Engine.workflow_finished(workflow_id, new_state)

    {:noreply, {definition, new_state, workflow_id}}
  end

  def handle_cast({:step_done, step_definition, step_id, step_state, next_step}, {definition, state, workflow_id}) do
    GenServer.stop({:global, step_id})

    new_state = Map.put(state, step_definition.id, step_state)

    execute_next_step(workflow_id, next_step, new_state)

    {:noreply, {definition, new_state, workflow_id}}
  end

  def execute_next_step(workflow_id, step_definition, state) do
    Traverse.Workflow.Step.start_step(workflow_id, step_definition, state)
  end
end
