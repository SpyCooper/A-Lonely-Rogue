extends Area2D

# sets the tp direction
enum door_position
{
	up,
	down,
	right,
	left,
}

# object references
@onready var marker_2d = $Marker2D
@export var tp_direction : door_position

# when the player enters the door teleporter, teleport the player to the next room
func _on_body_entered(body):
	if body is Player:
		if tp_direction == door_position.up:
			body.global_position += Vector2(0, -65)
		elif tp_direction == door_position.down:
			body.global_position += Vector2(0, 65)
		elif tp_direction == door_position.left:
			body.global_position += Vector2(-65, 0)
		elif tp_direction == door_position.right:
			body.global_position += Vector2(65, 0)
