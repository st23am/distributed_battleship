# distributed_battleship

## Summary

A battleship game controller orchestrates the distributed players. Each player is a Node on the erlang network
and can interact with the control with the following messsages:

* start-game will be cast to all players informing them of the size of the board.
* Each player will send a ship-at message allocating a space on the board for a ship type.
* The control will inform the players its time to take a turn and the player will return an x,y guess.
* Once all players have taken a turn the control will cast a feedback message to each player about their individual success.
* Then another turn will be initiated.


