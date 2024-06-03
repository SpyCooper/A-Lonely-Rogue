extends Enemy

class_name slime

# variables
var target_position
var current_direction : look_direction
var plaing_hit_animation = false

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var spawn_timer = $Spawn_timer
@onready var death_timer = $death_timer
@onready var hit_sound = $HitSound
@onready var death_sound = $DeathSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_sound_timer = $Spawn_sound_timer

func _ready():
	speed = .5
	health = 5
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
		else:
			sleep()
	)

func wake_up():
	player_in_room = true
	animated_sprite.play("spawning")
	spawn_timer.start()
	spawn_sound.play()

# called every frame
func _physics_process(_delta):
	if player_in_room && !dying && !spawning:
		# follows the player
		if player && Engine.time_scale != 0.0:
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
			if position.distance_to(player_position) > 10:
				move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	if spawning == false && dying == false:
		health -= damage
		if health > 0:
			if current_direction == look_direction.left:
				animated_sprite.play("hit_left")
			elif current_direction == look_direction.right:
				animated_sprite.play("hit_right")
			plaing_hit_animation = true
			hit_sound.play()
		if health <= 0:
			dying = true
			animated_sprite.play("dying")
			velocity = Vector2(0.0,0.0)
			death_timer.start()
			death_sound.play()

func get_animated_sprite():
	return animated_sprite

func spawned_in_room():
	player_in_room = true
	spawning = false

func _on_spawn_timer_timeout():
	spawning = false

func _on_death_timer_timeout():
	catalog.unlock_enemy(EnemyTypes.enemy.blue_slime)
	enemy_slain()
