extends Area2D

# collider is set to check layer 2 (which currently has the player)
# when the player enters the collider, damage the player
func _on_body_entered(body):
	# if the entered body has the function damage_player(), it will run it
	if body is Player:
		body.player_take_damage()
