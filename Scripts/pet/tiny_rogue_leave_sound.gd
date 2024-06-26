extends Node2D
@onready var timer = $Timer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _ready():
	audio_stream_player_2d.play()

func _on_timer_timeout():
	queue_free()
