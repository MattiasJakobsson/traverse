defmodule Traverse do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    
    opts = [strategy: :one_for_one, name: Traverse.Supervisor]

    children = [
      {Traverse.Engine, []},
      worker(Traverse.CronScheduler, [])
    ]

    Supervisor.start_link(children, opts)
  end
end
