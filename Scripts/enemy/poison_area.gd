extends Node2D

# object references
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var life_timer = $life_timer
@onready var area_2d = $Area2D
@onready var exit_timer = $exit_timer
@onready var enter_timer = $enter_timer
@onready var enter_sound = $enter_sound
@onready var exit_sound = $"exit sound"
@onready var timer = $Timer

# variables
var player_in_damage = false
var player

var enemies = []
var enemies_in_damage = false

# on ready
func _ready():
	# play the enter animation and start enter timer
	animated_sprite_2d.play("enter")
	enter_timer.start()
	# plays the enter sound
	enter_sound.play()

# when a body enters the hitbox
func _on_area_2d_body_entered(body):
	# if the entered body has the function damage_player(), it will run it
	if body is Player && !body.get_is_dying():
		player = body
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
		# starts the timer for the player staying in the damage field
		player_in_damage = true
		timer.start()
	# if the body is an enemy
	if body is Enemy:
		# deal 1 damage to that enemy
		body.take_damage(1, 0, true)
		# add the enemy to the list of enemies in the gas
		enemies += [body]
		# set that there are enemies in the area
		enemies_in_damage = true
		# if the timer hasn't started, start the damage timer
		if timer.is_stopped():
			timer.start()

# when a body leaves the hitbox (this is called before queue_free() is ran)
func _on_area_2d_body_exited(body):
	if body is Player:
		# the player no longer takes damage from the damage field
		player_in_damage = false
		timer.stop()
	# if the body is an enemy
	if body is Enemy:
		# remove the enemy from list of enemies
		for i in range(0, enemies.size()):
			if enemies[i] == body:
				enemies.remove_at(i)
		if enemies.size() == 0:
			# set that there are no enemies in the area
			enemies_in_damage = false
			# stop the damage timer
			timer.stop()

# when spawned
func spawned(pos):
	# set position (has to do with sorting and the ground)
	position = pos - area_2d.position

# when the enter timer ends
func _on_enter_timer_timeout():
	# start the life timer
	life_timer.start()

# when the life timer ends
func _on_life_timer_timeout():
	# play the exit animation and start exit timer
	animated_sprite_2d.play("exit")
	exit_timer.start()
	# plays the exit sound
	exit_sound.play()

# when the exit timer ends
func _on_exit_timer_timeout():
	# remove the vines
	queue_free()

# when the player take damage timer ends
func _on_timer_timeout():
	# damages the player if they are still in the field and are not dead and restarts the timer
	if player_in_damage && !player.get_is_dying():
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		player.player_take_damage(false, 0)
		timer.start()
	# if there are enemies in the area
	if enemies_in_damage:
		# deal 1 damage to each enemy
		for i in range(0, enemies.size()):
			enemies[i].take_damage(1, 0, true)

# gets the offset of the gas
func get_sprite_offset_position():
	return animated_sprite_2d.position
