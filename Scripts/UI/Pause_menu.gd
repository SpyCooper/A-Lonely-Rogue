extends Control

# object references
@onready var options_menu = $"../Options_menu"
@onready var catalog = $"../Catalog"

# on start, hide the pause menu
func _ready():
	hide()

# when an input is detected
func _input(event):
	# of the event is the paused button is pressed
	if event.is_action_pressed("Pause"):
		# if the game is not paused
		if Engine.time_scale > 0.0:
			# show the pause menu and pause the game
			show()
			Engine.time_scale = 0.0
		# if the game is paused
		else:
			# if the catalog menu is open, close it
			if catalog.visible:
				catalog.hide()
			# options menu is open
			elif options_menu.visible:
				# if the awaiting input screen is not open, close the options menu
				if !options_menu.is_input_screen_open():
					options_menu.hide()
				# if the awaiting input screen is open, hide it
				else:
					options_menu.input_screen_close()
			# if only the pause menu is open, close the pause menu
			else:
				hide()
				Engine.time_scale = 1.0

# when the resume button is pressed, close the pause menu and put the engine time scale to 1
func _on_resume_button_pressed():
	hide()
	Engine.time_scale = 1.0

# when the options button is pressed, show the options menu
func _on_options_button_pressed():
	options_menu.show()

# when the main menu button is pressed, switch scene to main menu
func _on_main_menu_button_pressed():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# when the catalog button is pressed, show the catalog
func _on_catalog_button_pressed():
	catalog.show()
