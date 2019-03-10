defmodule Traverse.Steps.Wait do
  use Traverse.Steps.Step

  def run_step(definition, _) do
    Traverse.Triggers.Trigger.start_trigger(definition.triggerSettings, %{}, 1)
    
    :started
  end

  def handle_cast({:trigger, {_, state}}, data) do
    done(state, :next)
    
    {:noreply, data}
  end
end
