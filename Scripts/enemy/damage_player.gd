extends Area2D

# object references
@onready var timer = $Timer

# variables
var player_in_damage = false
var player

# collider is set to check layer 2 (which currently has the player)
# when the player enters the collider, damage the player
func _on_body_entered(body):
	# if the entered body has the function damage_player(), it will run it
	if body is Player && !body.get_is_dying():
		body.player_take_damage(false, 0)
		
		# starts the timer for the player staying in the damage field
		player_in_damage = true
		player = body
		timer.start()

# when the player exits
func _on_body_exited(body):
	if body is Player:
		# the player no longer takes damage from the damage field
		player_in_damage = false
		timer.stop()

# when the timer ends
func _on_timer_timeout():
	# damages the player if they are still in the field and are not dead and restarts the timer
	if player_in_damage && !player.get_is_dying():
		player.player_take_damage(false, 0)
		timer.start()
