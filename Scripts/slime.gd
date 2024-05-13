extends CharacterBody2D

# constants
const SPEED = 25.0

# variables
var player_position
var target_position
var health = 3

# object references
@onready var player = %Player
@onready var animated_sprite = $AnimatedSprite2D

# called every frame
func _physics_process(delta):
	
	# follows the player
	if player:
		player_position = player.position
		target_position = (player_position - position).normalized()
		velocity = target_position * SPEED
		
		# flips the direction of the slime based on the if the target is on the left or right
		if target_position.x < 0:
			animated_sprite.play("look_left")
		elif target_position.x > 0:
			animated_sprite.play("look_right")

	# moves the slime
	if position.distance_to(player_position) > 1:
		move_and_slide()

# runs when a knife (or other weapon) hits the enemy
func hit():
	health -= 1
	if health <= 0:
		queue_free()
