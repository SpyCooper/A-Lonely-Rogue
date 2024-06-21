extends Node2D

# object references
@onready var fade_color = $CanvasLayer/Fade_color
@onready var animation_player = $CanvasLayer/Fade_color/AnimationPlayer
@onready var fade_timer = $CanvasLayer/Fade_color/Fade_timer
@onready var player = %Player
@onready var bg_music = $"BG music"

# variables
var fade_out = false
var fade_in = true
var next_floor

# on start
func _ready():
	# plays the fade in effect at the start of each floor
	fade_color.show()
	animation_player.play("fade_in")
	fade_in = true
	fade_timer.start()
	
	# when the floor_change signal is sent
	Events.floor_changed.connect(func(floor_to_be):
		# starts the fade out effect to switch floors
		next_floor = floor_to_be
		fade_color.show()
		animation_player.play("fade_out")
		fade_timer.start()
		fade_out = true
		
		# disables player movement
		player.player_can_move = false
		# saves player data to be transfered between scenes
		player.save_player_data()
	)

# when the fade timer ends
func _on_fade_timer_timeout():
	# if fade out is true, switch scenes to next floor
	if fade_out:
		get_tree().change_scene_to_file(next_floor)
	# if fade in is true, hide the fade color
	elif fade_in:
		fade_color.hide()
		fade_in = false

# plays the background music on the floor
# this is called after the player's fall
func play_bg_music():
	bg_music.play()

# stops the background music on the floor
func stop_bg_music():
	bg_music.stop()
