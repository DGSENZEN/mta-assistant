defmodule MtaExBackend do
  @moduledoc """ 
  Simple client to test an endpoint.
  """
  @python_service_endpoint "http://127.0.0.1:8000/test_endpoint"

  def test_post() do
    json_map = %{
      sender: "elixir_service",
      sender_id: 1,
      body: "This is a test POST!",
      timestamp: "#{DateTime.utc_now()}"
  
    }

    headers = [{"Content-Type", "application/json"}]

    {:ok, message} = Jason.encode(json_map)

    case HTTPoison.post(@python_service_endpoint, message, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("Success! Response sent to the Python service!")
        {:ok, decoded_message} = Jason.decode(body)
        IO.inspect(decoded_message, pretty: true)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Server responded with:#{status_code}")
        IO.puts("Body: #{body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("There was an error with communicating with the service! Error: #{reason}")
        IO.inspect(reason)
    end
  end
end
