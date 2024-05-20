extends Area2D

# object references
@onready var marker_2d = $Marker2D

@export var locked = false

func _on_body_entered(body):
	body.global_position = marker_2d.global_position

func is_locked():
	return locked
