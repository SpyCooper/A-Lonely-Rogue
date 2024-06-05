extends Node2D

# menu references
@onready var options_menu = $CanvasLayer/Options_menu
@onready var catalog = $CanvasLayer/Catalog

# fade object references
@onready var fade_color = $CanvasLayer/Fade_color
@onready var fade_timer = $CanvasLayer/Fade_color/Fade_timer
@onready var animation_player = $CanvasLayer/Fade_color/AnimationPlayer

# variables
var fade_out = false

# on ready
func _ready():
	# fade in
	fade_color.show()
	animation_player.play("fade_in")
	fade_timer.start()

# when the play button is pressed
func _on_play_button_pressed():
	# fade out
	fade_color.show()
	animation_player.play("fade_out")
	fade_out = true
	fade_timer.start()

# when the exit button is pressed
func _on_exit_button_pressed():
	# save the enemies and items
	catalog.save_enemies()
	catalog.save_items()
	# quit the application
	get_tree().quit()

# when the options button is pressed, show the options menu
func _on_options_button_pressed():
	options_menu.show()

# when the catalog button is pressed, show the catalog
func _on_catalog_button_pressed():
	catalog.show()

# fade the screen when switching and opening scenes
func _on_fade_timer_timeout():
	if fade_out:
		get_tree().change_scene_to_file("res://Scenes/Dungeon_floors/dungeon_floor_1.tscn")
	else:
		fade_color.hide()
