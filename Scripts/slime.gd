extends CharacterBody2D

enum look_direction
{
	right,
	left
}

# constants
const SPEED = 25.0

# variables
var player_position
var target_position
var health = 3
var current_direction : look_direction
var player_in_room = false

# object references
@onready var player = %Player
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	sleep()
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
		else:
			sleep()
	)

func sleep():
	player_in_room = false

func wake_up():
	player_in_room = true

# called every frame
func _physics_process(delta):
	if player_in_room:
		# follows the player
		if player:
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			velocity = target_position * SPEED
			
			# flips the direction of the slime based on the if the target is on the left or right
			if target_position.x < 0:
				current_direction = look_direction.left
				if animated_sprite.is_playing() == false:
					animated_sprite.play("look_left")
				elif animated_sprite.animation == "hit_right" :
					var frame = animated_sprite.frame
					animated_sprite.play("hit_left")
					animated_sprite.frame = frame
			elif target_position.x > 0:
				current_direction = look_direction.right
				if animated_sprite.is_playing() == false:
					animated_sprite.play("look_right")
				elif animated_sprite.animation == "hit_left" :
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame

		# moves the slime
		if position.distance_to(player_position) > 1:
			move_and_slide()

# runs when a knife (or other weapon) hits the enemy
func hit():
	health -= 1
	if current_direction == look_direction.left:
		animated_sprite.play("hit_left")
	elif current_direction == look_direction.right:
		animated_sprite.play("hit_right")
	if health <= 0:
		queue_free()
