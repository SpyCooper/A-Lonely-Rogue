extends Node2D

@onready var options_menu = $CanvasLayer/Options_menu

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	options_menu.show()


func _on_catalog_button_pressed():
	pass # Replace with function body.
