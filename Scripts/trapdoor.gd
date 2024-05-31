extends Node2D


func _on_area_2d_body_entered(body):
	print(body)
	if body is Player:
		## NOTE: this check uses the node name
		if get_tree().current_scene.name == "Layer1":
			get_tree().change_scene_to_file("res://Scenes/Dungeon_Layers/dungeon_layer_2.tscn")
