defmodule Traverse do
  use Application

  def start(_type, _args) do
    Traverse.Workflow.Engine.start_link([])
  end
end
