extends Node2D

# gets the audio reference
@onready var audio_stream_player = $AudioStreamPlayer2D


# when the player enters the portal area
func _on_teleporter_body_entered(body):
	# if the body is a player and the they are on the 5th floor
	if body is Player:
		Events.floor_changed.emit("res://Scenes/Dungeon_floors/game_won_2.tscn")
