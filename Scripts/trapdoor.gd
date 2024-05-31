extends Node2D


func _on_area_2d_body_entered(body):
	if body is Player:
		## NOTE: this check uses the node name
		if get_tree().current_scene.name == "Floor1":
			Events.floor_changed.emit("res://Scenes/Dungeon_floors/dungeon_floor_2.tscn")
