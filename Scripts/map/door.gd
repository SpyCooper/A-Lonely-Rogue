extends Area2D

# object references
@onready var marker_2d = $Marker2D

# when the player enters the door teleporter, teleport the player to the next room
func _on_body_entered(body):
	if body is Player:
		body.global_position = marker_2d.global_position
