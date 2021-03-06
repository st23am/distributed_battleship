defmodule AddingShips do
  @moduledoc "allow players to tell the commander where there ships will be"

  def tick(phase_context = %{service: %{trigger_pid: trigger_pid, turns_pid: turns_pid}}) do
    Phase.change?(trigger_pid, phase_context, :taking_turns, fn phase_context ->
      Turns.activate(turns_pid)
      phase_context
    end)
  end
end

