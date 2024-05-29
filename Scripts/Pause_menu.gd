extends Control

@onready var options_menu = $"../Options_menu"
@export var main_menu_scene:PackedScene

func _ready():
	hide()

func _input(event):
	## make an actual pause menu
	if event.is_action_pressed("Pause"):
		if Engine.time_scale > 0.0:
			show()
			Engine.time_scale = 0.0
		else:
			hide()
			Engine.time_scale = 1.0

func _on_resume_button_pressed():
	hide()
	Engine.time_scale = 1.0

func _on_options_button_pressed():
	options_menu.show()

func _on_main_menu_button_pressed():
	get_tree().paused = true
	get_tree().change_scene_to_packed(main_menu_scene)
