defmodule Traverse.Triggers.PhoenixPubSubTrigger do
  use Traverse.Triggers.Trigger

  def start(settings) do
    Phoenix.PubSub.subscribe(settings.server |> to_string |> String.to_atom, settings.topic)

    :ok
  end

  def stop(settings) do
    Phoenix.PubSub.unsubscribe(settings.server |> to_string |> String.to_atom, settings.topic)
    
    :ok
  end
  
  def handle_info({event_name, event_data}, definition) do
    if String.to_atom(definition.settings.event) == event_name do
      GenServer.cast(self(), {:trigger, {event_name, event_data}})
    end
    
    {:noreply, definition}
  end
end
