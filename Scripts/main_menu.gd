extends Node2D

@onready var options_menu = $CanvasLayer/Options_menu
@onready var catalog = $CanvasLayer/Catalog
@onready var moving_ground_animation = $"CanvasLayer/TileMap/moving ground animation"
@onready var animated_rogue = $CanvasLayer/Animated_Rogue

@onready var fade_color = $CanvasLayer/Fade_color
@onready var fade_timer = $CanvasLayer/Fade_color/Fade_timer
@onready var animation_player = $CanvasLayer/Fade_color/AnimationPlayer

func _ready():
	fade_color.hide()

func _on_play_button_pressed():
	fade_color.show()
	animation_player.play("fade_out")
	fade_timer.start()

func _on_exit_button_pressed():
	catalog.save_enemies()
	catalog.save_items()
	get_tree().quit()

func _on_options_button_pressed():
	options_menu.show()

func _on_catalog_button_pressed():
	catalog.show()


func _on_fade_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/Dungeon_floors/dungeon_floor_1.tscn")
