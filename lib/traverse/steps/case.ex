defmodule Traverse.Steps.Case do
  use Traverse.Steps.Step
  
  def run_step(definition, state) do
    matching_case = definition.cases 
    |> Enum.find(fn item -> 
      Traverse.ParameterInterpreter.compile_and_evaluate(item.case, state) == true 
    end)
    
    case matching_case do
      nil -> {nil, nil}
      item -> {Map.get(item, :next), Map.get(item, :state)}
    end
  end
end
