defmodule MtaExPoller.Poller do
  
  use GenServer
  require Logger
  
  @poll_interval_ms  30 * 1000


  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true 
  def init(state) do
    Logger.info("MTA Poller started!")
    schedule_poll(0)
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, info) do
    Logger.info("Polling MTA feed...")

    Task.async(fn -> perform_polling_work() end)

    schedule_poll(@poll_interval_ms)
    {:noreply, state}
  end

  defp schedule_poll(delay_ms) do
    Process.send_after(self(), :poll, delay_ms)
  end

  defp perform_polling_work() do
    case MtaExPoller.fetch_and_process_mta_feed() do
      {:ok, json_result} ->
        Logger.info("Fetched and sent the data to the service.")
        handle_sent_result(MtaExPoller.send_to_python_service(json_result))
      {:error, reason} ->
        Logger.error("Unable to perform the polling work: #{reason}")
    end
    
  end

  defp handle_sent_result({:ok, body}) do
    Logger.info("Data successfully sent to the Python service.")
  end

  defp handle_sent_result({:error, reason}) do
    Logger.error("Data unsucessfully sent to the Python service: #{reason}")
  end

end
