extends Node2D

# gets the audio reference
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

# when the player enters the trapdoor area
func _on_area_2d_body_entered(body):
	if body is Player:
		# play the trapdoor sound
		audio_stream_player_2d.play()
		# move to the next floor
		## NOTE: this check uses the node name
		if get_tree().current_scene.name == "Floor1":
			Events.floor_changed.emit("res://Scenes/Dungeon_floors/dungeon_floor_2.tscn")
		if get_tree().current_scene.name == "Floor2":
			Events.floor_changed.emit("res://Scenes/Dungeon_floors/dungeon_floor_3.tscn")
