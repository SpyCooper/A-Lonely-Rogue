extends Area2D

# object references
@onready var timer = $Timer

# variables
var player_in_damage = false
var player
var damage_timer_max = 1.0
var damage_timer = 0
var wait_timer = 0
var wait_timer_max = 0.02

# collider is set to check layer 2 (which currently has the player)
# when the player enters the collider, damage the player
func _on_body_entered(body):
	# if the entered body has the function damage_player(), it will run it
	if body is Player && !body.get_is_dying():
		if damage_timer > 0:
			# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
			body.player_take_damage(false, 0)
			damage_timer = damage_timer_max
		# starts the timer for the player staying in the damage field
		player_in_damage = true
		player = body
		
		if get_parent() is Enemy:
			wait_timer = wait_timer_max

func _process(delta):
	if damage_timer <= 0:
		if player_in_damage && !player.get_is_dying():
			# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
			player.player_take_damage(false, 0)
			print(get_parent())
			damage_timer = damage_timer_max
	elif damage_timer > 0:
		damage_timer -= delta
	
	if player_in_damage && wait_timer <= 0:
		get_parent().player_in_damage_area = true
	else:
		wait_timer -= delta

# when the player exits
func _on_body_exited(body):
	if body is Player:
		# the player no longer takes damage from the damage field
		player_in_damage = false
		#timer.stop()
		if get_parent() is Enemy:
			get_parent().player_in_damage_area = false

# when the timer ends
func _on_timer_timeout():
	# damages the player if they are still in the field and are not dead and restarts the timer
	if player_in_damage && !player.get_is_dying():
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		player.player_take_damage(false, 0)
		print(get_parent())
		timer.start()
