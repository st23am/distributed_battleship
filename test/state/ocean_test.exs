defmodule OceanTest do
  use ExUnit.Case

  setup() do
    pid = Ocean.start()

    on_exit(fn -> Ocean.stop(pid) end)

    [pid: pid]
  end

  test "stop the service" do
    {:ok, "Stopped"} = Ocean.stop()
  end

  test "add a ship", context do
    {:ok, response} = Ocean.add_ship(context.pid, "Ed", 0, 0, 0, 10)

    assert response == "Added"

    {:ok, ships} = Ocean.ships(context.pid)
    assert {"Ed", 0, 0, 0, 10} in ships
  end

  test "add more than one ship", context do
    {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 2)
    {:ok, "Added"} = Ocean.add_ship(context.pid, "Jim",  1, 0, 0, 4)

    {:ok, ships} = Ocean.ships(context.pid)
    assert {"Fred", 0, 0, 0, 2} in ships
    assert {"Jim", 1, 0, 0, 4} in ships
  end
end
