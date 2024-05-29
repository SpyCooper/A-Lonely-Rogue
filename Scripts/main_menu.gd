extends Node2D

@onready var options_menu = $CanvasLayer/Options_menu
@onready var catalog = $CanvasLayer/Catalog
@onready var moving_ground_animation = $"CanvasLayer/TileMap/moving ground animation"
@onready var animated_rogue = $CanvasLayer/Animated_Rogue

func _ready():
	get_tree().paused = false
	moving_ground_animation.play("move")
	animated_rogue.play("default")
	print("unpaused")

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")

func _on_exit_button_pressed():
	catalog.save_enemies()
	catalog.save_items()
	get_tree().quit()

func _on_options_button_pressed():
	options_menu.show()

func _on_catalog_button_pressed():
	catalog.show()
