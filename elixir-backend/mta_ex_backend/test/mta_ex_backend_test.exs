defmodule MtaExBackendTest do
  use ExUnit.Case
  doctest MtaExBackend

  test "greets the world" do
    assert MtaExBackend.hello() == :world
  end
end
