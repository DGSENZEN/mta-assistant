defmodule PbExtension do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0"

  extend TransitRealtime.FeedHeader, :nyct_feed_header, 1001,
    optional: true,
    type: NyctFeedHeader,
    json_name: "nyctFeedHeader"

  extend TransitRealtime.TripDescriptor, :nyct_trip_descriptor, 1001,
    optional: true,
    type: NyctTripDescriptor,
    json_name: "nyctTripDescriptor"

  extend TransitRealtime.TripUpdate.StopTimeUpdate, :nyct_stop_time_update, 1001,
    optional: true,
    type: NyctStopTimeUpdate,
    json_name: "nyctStopTimeUpdate"
end
