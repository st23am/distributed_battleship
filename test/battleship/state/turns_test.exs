defmodule TurnsTest do
  use ExUnit.Case

  setup do
    turns_pid= Turns.start()

    on_exit(fn -> 
      Turns.stop()
    end)

    %{turns_pid: turns_pid}
  end
  
  def setup_activate(context) do
    Turns.activate(context.turns_pid)
    :ok
  end

  def setup_registered_player(context) do
    Turns.registered_players(context.turns_pid, %{
      "Ed"   => "pid",
      "Jim"  => "pid",
      "Fred" => "pid",
      "Bob"  => "pid",
    })
    :ok
  end

  describe "control" do

    test "stop turns", context do
      assert {:ok, "Stopped"} == Turns.stop(context.turns_pid)
    end

    test "stop by name" do
      assert {:ok, "Stopped"} == Turns.stop()
    end
  end

  describe "activation" do
    setup :setup_registered_player

    test "fail turn if not active", context do
      {:error, "No turns accepted yet"} = Turns.take(context.turns_pid, "Ed", %{x: 5, y: 10})
    end

    test "allow turns when activated", context do
      {:error, "No turns accepted yet"} = Turns.take(context.turns_pid, "Ed", %{x: 5, y: 10})

      Turns.activate(context.turns_pid)

      {:ok} = Turns.take(context.turns_pid, "Ed", %{x: 5, y: 10})
    end

    test "test is active", context do
      assert false == Turns.is_active(context.turns_pid)

      Turns.activate(context.turns_pid)

      assert true == Turns.is_active(context.turns_pid)

      Turns.deactivate(context.turns_pid)

      assert false == Turns.is_active(context.turns_pid)
    end
  end

  describe "registered players" do
    test "send", context do
      Turns.registered_players(context.turns_pid, %{"name": "pid"})
    end
  end

  describe "unregistered players" do
    setup :setup_activate

    test "can not take turns", context do
      Turns.registered_players(context.turns_pid, %{"Registered": "pid"})

      assert {:error, "You are not registered Unregistered"} = Turns.take(context.turns_pid, "Unregistered", %Position{x: 5, y: 10})
    end
  end

  describe "take turn" do
    setup :setup_activate
    setup :setup_registered_player

    test "turn", context do
      assert {:ok} = Turns.take(context.turns_pid, "Ed", %Position{x: 5, y: 10})
    end

    test "with raw parameters", context do
      assert {:ok} = Turns.take(context.turns_pid, "Ed", %{x: 5, y: 10})
    end
  end

  describe "process" do
    setup :setup_activate
    setup :setup_registered_player

    test "get turns", context do
      result= Turns.get(context.turns_pid)

      assert result == []
    end

    test "take a turn and get it", context do
      {:ok} = Turns.take(context.turns_pid, "Ed", %Position{x: 5, y: 10})

      result = Turns.get(context.turns_pid)

      assert result == [{"Ed", %Position{x: 5, y: 10}}]
    end
    
    test "take many turns and get them", context do
      {:ok} = Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: 11})
      {:ok} = Turns.take(context.turns_pid, "Jim",  %Position{x: 2, y: 12})
      {:ok} = Turns.take(context.turns_pid, "Fred", %Position{x: 3, y: 13})
      {:ok} = Turns.take(context.turns_pid, "Bob",  %Position{x: 4, y: 14})

      result = Turns.get(context.turns_pid)

      assert result == [
        {"Ed",   %Position{x: 1, y: 11}},
        {"Jim",  %Position{x: 2, y: 12}},
        {"Fred", %Position{x: 3, y: 13}},
        {"Bob",  %Position{x: 4, y: 14}},
      ]
    end

    test "ensure that all turns are returned at once and the next are none", context do
      {:ok} = Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: 11})

      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.turns_pid)

      assert [] == Turns.get(context.turns_pid)
      assert [] == Turns.get(context.turns_pid)
      assert [] == Turns.get(context.turns_pid)
      assert [] == Turns.get(context.turns_pid)
    end

    test "repeat the turn and get sequence", context do
      Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.turns_pid)

      Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.turns_pid)

      Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.turns_pid)

      Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.turns_pid)
    end
  end

  describe "wrong types of coordinate" do
    setup :setup_activate

    test "string x coord", context do
      result = Turns.take(context.turns_pid, "Ed",   %Position{x: "1", y: 11})

      assert result == {:error, "position must be numeric"}
    end
    test "string y coord", context do
      result = Turns.take(context.turns_pid, "Ed",   %Position{x: 1, y: "11"})

      assert result == {:error, "position must be numeric"}
    end
  end

  describe "wrong types of player name" do
    setup :setup_activate
    setup :setup_registered_player

    test "should be string", context do
      {:error, "Player name must be a string"} = Turns.take(context.turns_pid, %{not: "a string"}, %Position{x: 1, y: 1})
    end
  end
end

