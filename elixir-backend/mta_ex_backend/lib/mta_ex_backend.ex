defmodule MtaExPoller do
  @moduledoc """ 
  Simple client to test an endpoint.
  """
  alias TransitRealtime.FeedMessage
  
  @python_service_endpoint "http://127.0.0.1:8000/elixir_listener"
  @mta_realtime_endpoint "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-nqrw"

  def fetch_mta_feed() do
    with {:ok, fetched_protobuf} <- get_mta_rt_feed(),
      {:ok, json_payload} <- decode_encode_protobuf(fetched_protobuf) do
        {:ok, json_payload}
      end
  end
                                          
  def send_to_python_service(json_payload) do
    headers = [{"Content-Type", "application/json"}]
    options = [recv_timeout: 5000]
    body = Jason.encode!(%{"mta_data" => Jason.decode!(json_payload)})

    case HTTPoison.post(@python_service_endpoint, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, "Succesfully sent the JSON to the Python service: 200, #{body}"}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Service responded with: #{status_code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Had an error communicating with the Python service: #{reason}"}

    end
    
  end

  defp get_mta_rt_feed() do
    headers = [{"Content-Type", "application/x-protobuf"}]
    options = [recv_timeout: 5000]

    case HTTPoison.get(@mta_realtime_endpoint, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "MTA API responded with #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Could not fetch MTA feed: #{reason}"}
    end
  end 

  defp decode_encode_protobuf(binary_body) do
    try do
      decoded_protobuf = FeedMessage.decode(binary_body)
      json_payload = Protobuf.JSON.encode(decoded_protobuf)
    rescue
      e -> {:error, "Protobuf processing failed #{e}"}
    end
  end

end
