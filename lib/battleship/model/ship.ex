defmodule Ship do
  defstruct player: "Anonymous", from: %Position{}, to: %Position{}, strikes: []

  def new(player, from_x, from_y, to_x, to_y, strikes \\ []) do
    new(player, Position.new(from_x, from_y), Position.new(to_x, to_y), strikes)
  end

  def new(player, from, to, strikes \\ []) do
    %Ship{player: player, from: from, to: to, strikes: strikes}
  end

  def at?(ship, position) do
    Collision.intersect(
      {ship.from.x, ship.from.y}, {ship.to.x, ship.to.y},
      {position.x, position.y}, {position.x, position.y})
  end

  def strike(ship, x, y) do
    at?(ship, Position.new(x, y))
    |> strike_or_miss(ship, Position.new(x, y))
  end

  def struck?(ship, position) do
    Enum.any?(ship.strikes, fn strike -> strike == position end)
  end

  defp strike_or_miss(false, ship, _osition), do: ship
  defp strike_or_miss(true,  ship, position) do
    Map.merge(ship, %{strikes: ship.strikes ++ [position]})
  end
end
