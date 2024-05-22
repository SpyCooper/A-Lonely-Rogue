extends Enemy

class_name slime

# variables
var target_position
var current_direction : look_direction
var plaing_hit_animation = false

# object references
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	speed = .5
	health = 3
	sleep()
	player = Events.player
	max_health = health
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
			spawning = false
		else:
			sleep()
	)

# called every frame
func _physics_process(_delta):
	if player_in_room:
		# follows the player
		if player:
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			
			# flips the direction of the slime based on the if the target is on the left or right
			if current_direction == look_direction.left:
				if animated_sprite.animation == "hit_right" :
					var frame = animated_sprite.frame
					animated_sprite.play("hit_left")
					animated_sprite.frame = frame
				elif plaing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("look_left")
					plaing_hit_animation = false
			elif current_direction == look_direction.right:
				if animated_sprite.animation == "hit_left" :
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame
				elif plaing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("look_right")
					plaing_hit_animation = false
		
			# moves the slime
			if position.distance_to(player_position) > 1:
				move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	health -= damage
	if current_direction == look_direction.left:
		animated_sprite.play("hit_left")
	elif current_direction == look_direction.right:
		animated_sprite.play("hit_right")
	plaing_hit_animation = true
	if health <= 0:
		enemy_slain()

func get_animated_sprite():
	return animated_sprite

func spawned_in_room():
	player_in_room = true
