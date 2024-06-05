extends Node

# creates events the game uses
signal room_entered(room)
signal floor_changed(floor)

# references to the player and catalog are set by the player and the catalog in the scene
var player
var catalog
