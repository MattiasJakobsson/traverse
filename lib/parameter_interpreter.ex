defmodule Traverse.ParameterInterpreter do
  def eval_code(source, data) when is_map(source) do
    source 
    |> Enum.map(fn {key, value} -> {key, eval_code(value, data)} end)
    |> Enum.into(%{})
  end

  def eval_code(source, data) when is_binary(source) do
    case Regex.run(~r/(?s)^\{\{(.+?)\}\}$/, source) do
      [_, item] -> compile_and_evaluate(item, data)
      _ -> source
    end
  end

  def eval_code(source, _), do: source
  
  def compile_and_evaluate(expression, data) do
    expression 
    |> to_charlist() 
    |> :parameter_lexer.string()
    |> fn ({:ok, tokens, _}) -> :parameter_parser.parse(tokens) end.()
    |> fn ({:ok, ast}) -> eval(ast, data) end.()
  end
  
  defp eval({:const, item}, _), do: item
  defp eval({:variable, key}, data), do: get_path(String.split(key |> to_string, "."), data)
  
  defp eval({:compare, '==', lhs, rhs}, data), do: eval(lhs, data) == eval(rhs, data)
  defp eval({:compare, '!=', lhs, rhs}, data), do: eval(lhs, data) != eval(rhs, data)
  defp eval({:compare, '>', lhs, rhs}, data), do: eval(lhs, data) > eval(rhs, data)
  defp eval({:compare, '<', lhs, rhs}, data), do: eval(lhs, data) < eval(rhs, data)
  defp eval({:compare, '>=', lhs, rhs}, data), do: eval(lhs, data) >= eval(rhs, data)
  defp eval({:compare, '<=', lhs, rhs}, data), do: eval(lhs, data) <= eval(rhs, data)

  defp eval({:ternary, condition, true_case, false_case}, data) do
    case eval(condition, data) do
      true -> eval(true_case, data)
      _ -> eval(false_case, data)
    end
  end

  defp eval({:null_check, lhs, rhs}, data) do
    case eval(lhs, data) do
      nil -> eval(rhs, data)
      item -> item
    end
  end

  defp get_path([current], data) when is_map(data), do: Map.get(data, current |> String.to_atom)
  defp get_path([current | tail], data) when is_map(data), do: get_path(tail, Map.get(data, current |> String.to_atom))
  defp get_path(_, _), do: nil
end
