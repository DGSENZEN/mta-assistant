defmodule MtaExPoller do
  @moduledoc """ 
  Simple client to test an endpoint.
  """
  alias TransitRealtime.FeedMessage
  
  @python_service_endpoint "http://127.0.0.1:8000/elixir_listener"
  @mta_realtime_endpoint "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-nqrw"

  def mta_realtime_feed_protobuf() do
    case process_protobuf() do
      {:ok, payload} ->
        payload_map = %{"mta_data" => Jason.decode!(payload)}
        case HTTPoison.post(@python_service_endpoint, Jason.encode!(payload_map), [{"Content-Type", "application/json"}]) do 
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            IO.puts("[mta_realtime_feed_protobuf]: Success! Sent the MTA feed to the Python service!")
            IO.inspect(body)

          {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
            IO.puts("[mta_realtime_feed_protobuf]: Server responded with: #{status_code}")
            IO.puts("Body: #{body}")


          {:error, %HTTPoison.Error{reason: reason}} ->
            IO.puts("[mta_realtime_feed_protobuf]: There was an error with communicating with the Python service! Error: #{reason}")
            IO.inspect(reason)
        end
      
      other ->
        IO.puts("[mta_realtime_feed_protobuf]: Unable to send the protobuf to the Python service")
        IO.inspect(other)
      end
  end

  def process_protobuf() do
    case HTTPoison.get(@mta_realtime_endpoint, [{"Content-Type", "application/x-protobuf"}], recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("[process_protobuf]: Success! Obtained the protobuf binary for processing.")
        processed_protobuf = FeedMessage.decode(body)
        json_payload = Protobuf.JSON.encode(processed_protobuf)
        IO.puts("[process_protobuf]: Successful processing of protobuf.")
        json_payload

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("[process_protobuf]: Service responded with: #{status_code}, #{body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("[process_protobuf]: Error!")
        IO.inspect(reason)
    end
  end



end
