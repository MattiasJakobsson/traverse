defmodule Traverse.Workflow do
  use GenServer
  
  defmodule Definition do
    defstruct workflow_id: nil,
              workflow_definition: %{},
              current_state: %{}
  end

  def start_workflow(definition, initial_state) do
    workflow_definition = %Definition{workflow_id: UUID.uuid4(), workflow_definition: definition, current_state: initial_state}

    GenServer.start_link(
      __MODULE__,
      workflow_definition,
      name: {:global, workflow_definition.workflow_id}
    )

    workflow_definition
  end

  #TODO: Remove in favor of pub/sub communication
  def step_finished(workflow_id, step_definition, step_id, state, next_step) do
    GenServer.cast({:global, workflow_id}, {:step_done, {step_definition, step_id, state, next_step}})
  end

  def init(definition) do
    GenServer.cast(self(), :start)
    
    {:ok, definition}
  end

  def handle_cast(:start, definition) do
    Traverse.Steps.Step.start_step(definition.workflow_id, definition.step_definition, definition.current_state)

    {:noreply, definition}
  end
  
  def handle_cast({:step_done, {step_definition, step_id, step_state, next_step}}, definition) do
    GenServer.stop({:global, step_id})

    new_definition = Map.put(definition, :current_state, Map.put(definition.current_state, String.to_atom(step_definition.id), step_state))
    
    #TODO: Pub/sub instead of static finished call
    case next_step do
      nil -> Traverse.Engine.workflow_finished(new_definition.workflow_id, new_definition.current_state)
      step -> Traverse.Steps.Step.start_step(definition.workflow_id, step, new_definition.current_state)
    end

    {:noreply, new_definition}
  end
end
