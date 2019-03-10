defmodule Traverse.ParameterInterpreter do
  def compile_and_evaluate(expression, data) do
    expression 
    |> to_charlist() 
    |> :parameter_lexer.string()
    |> fn ({:ok, tokens, _}) -> :parameter_parser.parse(tokens) end.()
    |> fn ({:ok, ast}) -> eval(ast, data) end.()
  end
  
  defp eval({:const, item}, _), do: item
  defp eval({:variable, key}, data) do
    Map.get(data, key |> to_string |> String.to_atom)
  end
  
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
end
