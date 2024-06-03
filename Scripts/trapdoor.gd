extends Node2D

@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _on_area_2d_body_entered(body):
	if body is Player:
		audio_stream_player_2d.play()
		## NOTE: this check uses the node name
		if get_tree().current_scene.name == "Floor1":
			Events.floor_changed.emit("res://Scenes/Dungeon_floors/dungeon_floor_2.tscn")
