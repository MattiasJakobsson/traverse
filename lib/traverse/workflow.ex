defmodule Traverse.Workflow do
  use GenServer
  
  defmodule Definition do
    defstruct workflow_id: nil,
              workflow_definition: %{},
              current_state: %{},
              parent: nil
  end

  def start_workflow(definition, initial_state, parent \\ self()) do
    workflow_definition = %Definition{workflow_id: UUID.uuid4(), workflow_definition: definition, current_state: initial_state, parent: parent}

    GenServer.start_link(
      __MODULE__,
      workflow_definition,
      name: {:global, workflow_definition.workflow_id}
    )

    workflow_definition
  end

  def init(definition) do
    Traverse.Steps.Step.start_step(definition.workflow_id, definition.step_definition, definition.current_state)
    
    {:ok, definition}
  end
  
  def handle_cast({:step_done, {step_id, step_state, next_step}}, definition) do
    GenServer.stop({:global, step_id})

    new_definition = Map.put(definition, :current_state, Map.put(definition.current_state, String.to_atom(step_id), step_state))
    
    case next_step do
      nil -> GenServer.cast(definition.parent, {:execution_finished, {new_definition.workflow_id, new_definition.current_state}})
      step -> Traverse.Steps.Step.start_step(new_definition.workflow_id, step, new_definition.current_state)
    end

    {:noreply, new_definition}
  end
end
