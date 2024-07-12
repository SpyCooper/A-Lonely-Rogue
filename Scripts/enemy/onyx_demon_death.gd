extends Node2D

@onready var audio_stream_player_2d = $AudioStreamPlayer2D

# plays the death audio when spawned
func spawned():
	audio_stream_player_2d.play()

# when the audio ends, remove the object
func _on_audio_stream_player_2d_finished():
	queue_free()
