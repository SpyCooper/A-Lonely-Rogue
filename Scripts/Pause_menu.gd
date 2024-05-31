extends Control

@onready var options_menu = $"../Options_menu"
@onready var catalog = $"../Catalog"

func _ready():
	hide()

func _input(event):
	## make an actual pause menu
	if event.is_action_pressed("Pause"):
		if Engine.time_scale > 0.0:
			show()
			Engine.time_scale = 0.0
		else:
			if catalog.visible:
				catalog.hide()
			elif options_menu.visible:
				options_menu.hide()
			else:
				hide()
				Engine.time_scale = 1.0

func _on_resume_button_pressed():
	hide()
	Engine.time_scale = 1.0

func _on_options_button_pressed():
	options_menu.show()

func _on_main_menu_button_pressed():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_catalog_button_pressed():
	catalog.show()
