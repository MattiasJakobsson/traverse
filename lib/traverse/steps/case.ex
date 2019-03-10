defmodule Traverse.Steps.Case do
  use Traverse.Steps.Step
  
  def run_step(definition, state) do
    case definition.cases |> Enum.find(fn item -> Traverse.ParameterInterpreter.compile_and_evaluate(item.case, state) == true end) do
      nil -> {nil, nil}
      item -> {item.next, nil}
    end
  end
end
