extends Control

@onready var options_menu = $"../Options_menu"

func _ready():
	hide()

func _input(event):
	## make an actual pause menu
	if event.is_action_pressed("Pause"):
		show()
		Engine.time_scale = 0.0

func _on_resume_button_pressed():
	hide()
	Engine.time_scale = 1.0

func _on_options_button_pressed():
	options_menu.show()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
