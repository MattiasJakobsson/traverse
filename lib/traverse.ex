defmodule Traverse do
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Traverse.Supervisor]

    Supervisor.start_link(children(), opts)
  end

  def children() do
    [
      {Traverse.Workflow.Engine, []}
    ]
  end
end
