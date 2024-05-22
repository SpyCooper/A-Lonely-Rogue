extends Area2D

var player_in_damage = false
@onready var timer = $Timer
var player

# collider is set to check layer 2 (which currently has the player)
# when the player enters the collider, damage the player
func _on_body_entered(body):
	# if the entered body has the function damage_player(), it will run it
	if body is Player:
		body.player_take_damage()
		player_in_damage = true
		player = body
		timer.start()

func _on_body_exited(_body):
	player_in_damage = false
	timer.stop()


func _on_timer_timeout():
	if player_in_damage == true:
		player.player_take_damage()
		timer.start()
