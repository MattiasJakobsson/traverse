defmodule Traverse.Workflow.PhoenixPubSubTrigger do
  use Traverse.Workflow.Trigger

  def start(settings) do
    Phoenix.PubSub.subscribe(String.to_atom(settings["server"]), settings["topic"])

    :ok
  end

  def stop(settings) do
    Phoenix.PubSub.unsubscribe(String.to_atom(settings["server"]), settings["topic"])
    
    :ok
  end
  
  def handle_info({event_name, event_data}, {settings, workflow}) do
    if settings["event"] == String.to_atom(event_name) do
      GenServer.cast(self(), {:trigger, {event_name, event_data}})
    end
    
    {:noreply, {settings, workflow}}
  end
end
