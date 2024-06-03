extends Node2D

@onready var fade_color = $CanvasLayer/Fade_color
@onready var animation_player = $CanvasLayer/Fade_color/AnimationPlayer
@onready var fade_timer = $CanvasLayer/Fade_color/Fade_timer
@onready var player = %Player
@onready var bg_music = $"BG music"

var fade_out = false
var fade_in = true
var next_floor

func _ready():
	fade_color.show()
	animation_player.play("fade_in")
	fade_in = true
	
	Events.floor_changed.connect(func(floor_to_be):
		next_floor = floor_to_be
		fade_color.show()
		animation_player.play("fade_out")
		fade_timer.start()
		fade_out = true
		player.player_can_move = false
		player.save_player_data()
	)

func _on_fade_timer_timeout():
	if fade_out:
		get_tree().change_scene_to_file(next_floor)
	if fade_in:
		fade_color.hide()
		bg_music.play()
		fade_in = false
