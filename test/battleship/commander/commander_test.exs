defmodule CommanderTest do
  use ExUnit.Case

  setup() do
    on_exit(fn -> Players.stop() end)
  end

  def fake_phase(phase_context = %{test_phases: [next_phase | rest_of_phases]}) do
    Map.merge(phase_context, %{new_phase: next_phase, test_phases: rest_of_phases})
  end

  def fake_phase(phase_context = %{stop_next_call: true}) do
    Map.merge(Map.delete(phase_context, :stop_next_call), %{new_phase: :finish})
  end

  def fake_phase(phase_context) do
    Map.merge(phase_context, %{stop_next_call: true})
  end

  def fake_finish(phase_context) do
    Map.merge(phase_context, %{game_over: true})
  end

  describe "tick" do
    test "trigger an action on a tick" do
      context = Commander.play(:none,
        %{
          :none => %{ test_phases: [:finish] }
        },
        [
          none: &CommanderTest.fake_phase/1,
          finish: &CommanderTest.fake_finish/1
        ])

      assert context.tick_count == 2
    end

    test "run two ticks" do
      phases = [
        none: &CommanderTest.fake_phase/1,
        finish: &CommanderTest.fake_finish/1
      ]

      context = Commander.play(:none, 
        %{         
          :none => %{test_phases: [:none,:finish]},
          :finish => %{test_phases: []}
        }, phases)

      assert context.tick_count == 3
    end
  end

  describe "all the phases" do
    test "change phases" do
      phases = Enum.map(Commander.phases, fn {name, _} ->
        case name do
          :finish -> {name, &CommanderTest.fake_finish/1}
          _       -> {name, &CommanderTest.fake_phase/1} 
        end
      end)

      context = %{}
        |> Map.merge(%{none:                %{test_phases: [:waiting_for_players]}})
        |> Map.merge(%{waiting_for_players: %{test_phases: [:start_game]}})
        |> Map.merge(%{start_game:          %{test_phases: [:adding_ships]}})
        |> Map.merge(%{adding_ships:        %{test_phases: [:taking_turns]}})
        |> Map.merge(%{taking_turns:        %{test_phases: [:finish]}})

      context = Commander.play(:none, context, phases)

      assert context.tick_count == 6
    end

    test "dont chnage phase if there is no new_state" do
      context = Commander.play( :none, %{ :none => %{} }, [
        none: &CommanderTest.fake_phase/1,
        finish: &CommanderTest.fake_finish/1
      ])

      assert context.track_phase == [:none, :none, :finish]
    end
    
  end

  test "should ensure that a phase name is spelled correctly" do
    refute Commander.valid_phase?(nil)
    refute Commander.valid_phase?("")
    refute Commander.valid_phase?(:invalid)

    Enum.each Commander.phase_names(), fn phase ->
      assert Commander.valid_phase?(phase)
    end
  end

  describe "initialize the services" do
    test "players service is started" do
      context = Commander.initialize()

      assert Process.alive?(context.service.players_pid), "didn't generate a players pid"
      assert Process.alive?(context.service.ocean_pid), "didn't generate a ocean pid"
      assert Process.alive?(context.service.trigger_pid), "didn't generate a trigger pid"
      assert Process.alive?(context.service.turns_pid), "didn't generate a turns pid"
    end
  end

  describe "deinitialize the services" do
    test "all servies should be stopped" do
      context = Commander.initialize()
      Commander.deinitialize()

      refute Process.alive?(context.service.players_pid), "didn't stop a players service"
      refute Process.alive?(context.service.ocean_pid), "didn't stop a ocean service"
      refute Process.alive?(context.service.trigger_pid), "didn't stop a trigger service"
      refute Process.alive?(context.service.turns_pid), "didn't stop a turns service"
    end
  end

  describe "context to phase interface" do
    test "add service to phase data" do
      context = Phase.run(%{phase: :none, service: %{}}, [none: &CommanderTest.fake_phase/1]) 

      assert context.none
      assert context.none.service
    end

    test "add service to phase data when there is none" do
      context = Phase.run(%{phase: :none}, [none: &CommanderTest.fake_phase/1]) 

      assert context.none
      refute Map.has_key?(context.none, :service)
    end
  end
end

