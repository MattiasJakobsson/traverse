defmodule Traverse.Triggers.CronTrigger do
  use Traverse.Triggers.Trigger

  def start(settings) do
    {:ok, parsed_schedule} = Crontab.CronExpression.Parser.parse(settings.schedule, true)
    
    me = self()
    
    Traverse.CronScheduler.new_job()
      |> Quantum.Job.set_name(String.to_atom(settings.name))
      |> Quantum.Job.set_schedule(parsed_schedule)
      |> Quantum.Job.set_task(fn -> GenServer.cast(me, :trigger) end)
      |> Traverse.CronScheduler.add_job()
    
    :ok
  end
  
  def stop(settings) do
    Traverse.CronScheduler.delete_job(String.to_atom(settings.name))
    
    :ok
  end
end
