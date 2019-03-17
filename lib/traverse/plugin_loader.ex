defmodule Traverse.PluginLoader do
  def find_all_plugin_types(plugin_type) do
    available_modules(plugin_type) |> Enum.reduce([], &load_plugin/2)
  end

  defp load_plugin(module, modules) do
    if Code.ensure_loaded?(module), do: [module | modules], else: modules
  end

  defp available_modules(plugin_type) do
    Mix.Task.run("loadpaths", [])

    Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && plugin_type in behaviours end)
    |> Enum.uniq
    |> Enum.map(fn {module, _} -> module end)
  end
end
