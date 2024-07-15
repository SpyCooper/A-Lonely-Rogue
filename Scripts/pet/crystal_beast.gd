extends StaticBody2D

enum state
{
	spawning,
	attacking,
	idle,
}

enum direction
{
	left,
	right,
}

@onready var animated_sprite = $AnimatedSprite2D
@onready var enter_sound = $enter_sound
@onready var hit_sound = $hit_sound
@onready var attack_sound = $attack_sound
@onready var attack_timer = $attack_timer
@onready var chromatic_orb_sprite = $chromatic_orb_sprite
@onready var spawn_timer = $spawn_timer
@onready var attack_start_timer = $attack_start_timer
@onready var attack_end_timer = $attack_end_timer
@onready var attack_after_spawning = $attack_after_spawning
@onready var laser_spawn_left = $laser_spawn_left
@onready var laser_spawn_right = $laser_spawn_right
const CHROMATIC_LASER = preload("res://Scenes/pets/chromatic_laser.tscn")
const HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")

var room_ref = null
var can_attack = false
var current_look_direction = direction.left
var current_state = state.spawning
var target = null
# pet variables
var angle = 0.0
var max_health = 1
var health = 1
var speed = 0.10


func _ready():
	# sets the pet variables
	speed = .05
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		# track the current_room
		room_ref = room
		if room_ref.get_enemies_in_room().size() != 0:
			spawn_in()
	)

# called on set intervals
func _physics_process(_delta):
	if Engine.time_scale != 0.0:
		## does not look at the player like the charms do
		# if the player is in a room
		if room_ref != null:
			if current_state != state.spawning:
				# if the room has enemies
				if room_ref.is_enemies():
					if room_ref.get_enemies_in_room().size() != 0:
						target = room_ref.get_enemies_in_room()[0]
						look_at_enemy()
					# if the rogue can throw
					if can_attack:
						attack()
					elif current_state == state.idle:
						if current_look_direction == direction.right:
							animated_sprite.play("idle_right")
						elif current_look_direction == direction.left:
							animated_sprite.play("idle_left")
				else:
					if animated_sprite.animation != "idle_left" || animated_sprite.animation != "idle_right":
						animated_sprite.play("idle_left")

# when the pet takes damage
func take_damage(_damage):
	pass

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the rogue to attack
	can_attack = true

# remove the pet
func kill_pet():
	enter_sound.play()
	# removes the pet
	queue_free()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

func spawn_in():
	global_position = room_ref.global_position - animated_sprite.position
	
	
	can_attack = false
	current_look_direction = direction.left
	current_state = state.spawning
	target = null
	
	current_state = state.spawning
	animated_sprite.play("spawn")
	chromatic_orb_sprite.show()
	chromatic_orb_sprite.play("default")
	# plays the pet enter sound
	enter_sound.play()
	spawn_timer.start()

func _on_spawn_timer_timeout():
	chromatic_orb_sprite.hide()
	# reset the attacks
	current_state = state.idle
	animated_sprite.play("idle_left")
	animated_sprite.play()
	attack_after_spawning.start()

func look_at_enemy():
	if target != null:
		if target.global_position.x > animated_sprite.global_position.x:
			current_look_direction = direction.right
		else:
			current_look_direction = direction.left

func attack():
	# disable can spawn
	can_attack = false
	current_state = state.attacking
	
	if current_look_direction == direction.right:
		animated_sprite.play("attack_right")
	else:
		animated_sprite.play("attack_left")
	
	attack_start_timer.start()

func _on_attack_start_timer_timeout():
	spawn_projectile()
	attack_end_timer.start()

func spawn_projectile():
	# play the attack sound
	attack_sound.play()
	
	var laser = CHROMATIC_LASER.instantiate()
	laser.position = self.global_position
	target = room_ref.get_enemies_in_room()[0]
	for enemy in room_ref.get_enemies_in_room():
		if enemy != null:
			target = enemy
	get_tree().current_scene.add_child(laser)
	var move_direction = target.get_animated_sprite().global_position - laser.global_position
	if current_look_direction == direction.right:
		laser.global_position = laser_spawn_left.global_position
		move_direction = target.get_animated_sprite().global_position - laser_spawn_left.global_position
	else:
		laser.global_position = laser_spawn_right.global_position
		move_direction = target.get_animated_sprite().global_position - laser_spawn_right.global_position
	
	move_direction = move_direction.normalized()
	laser.spawned(move_direction)

func _on_attack_end_timer_timeout():
	# start the attack timer
	attack_timer.start()
	current_state = state.idle

func _on_attack_after_spawning_timeout():
	can_attack = true

# resets the pet's hp
func reset_hp():
	health = max_health

# sets the pet's hp
func set_pet_hp(hp):
	health = hp

# melee damage for a pet
func _on_body_entered(_body):
	pass
