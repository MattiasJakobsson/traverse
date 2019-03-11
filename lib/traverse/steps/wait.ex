defmodule Traverse.Steps.Wait do
  use Traverse.Steps.Step

  def run_step(definition, state) do
    Traverse.Triggers.Trigger.start_trigger(Traverse.ParameterInterpreter.eval_code(definition.triggerSettings, state), %{}, 1)
    
    :started
  end

  def handle_cast({:trigger, {_, state}}, data) do
    done({:next, state})
    
    {:noreply, data}
  end
end
