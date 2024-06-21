extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var spawn_timer = $Spawn_timer
@onready var hud = %HUD
@onready var hit_animation_timer = $AnimatedSprite2D/hit_animation_timer
const PLAYER_SHADER = preload("res://Scripts/shaders/player.tres")
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound

@onready var direction_change_timer = $direction_change_timer
var current_move_direction

# defines a random number generator
var rng = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var playing_hit_animation = false
var can_attack = false
var can_move = true

## PLAYER VARIABLES
# constants
const KNIFE_SPEED = 150.0

# variables
var attacks_per_second = 1
var attack_damage = 1
var time_to_fire = 0.0
var time_to_fire_max = 1.0
#var speed = 100.0
#var dying = false
@onready var woosh_sound = $woosh_sound

# upgrade variables
var dust_blade = false
var triple_blades = false
var current_type : BladeType.blade_type = BladeType.blade_type.default
const ENEMY_KNIFE = preload("res://Scenes/enemy_knife.tscn")

# on start
func _ready():
	# basic enemy stats
	speed = 1.0
	max_health = 1
	health = max_health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()

# defines the wake_up function needed for the lich
## this is called by the rooms when a player enters it
func wake_up():
	player.save_player_data()
	
	# sets the stats for the player
	attacks_per_second = 1
	time_to_fire_max = time_to_fire_max / attacks_per_second
	
	load_player_data()
	
	player_in_room = true
	# runs spawn_in()
	spawn_in()
	# starts the attack timer
	attack_timer.start()

# runs on every frame
func _process(delta):
	# if the time to fire is above 0, it reduces the timer
	if time_to_fire > 0:
		time_to_fire -= delta

# called every frame
func _physics_process(_delta):
	# if the player is in the room, not dying, and not spawning
	if player_in_room && !dying && !spawning:
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_look_direction(target_position)
			# if the enemy can move (cannot move when attacking)
			if can_move:
				# flips the direction of the lich based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					animated_sprite.play("move_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("move_right")
				## Move up
				elif current_direction == look_direction.up:
					animated_sprite.play("move_up")
				## Move down
				elif current_direction == look_direction.down:
					animated_sprite.play("move_down")
				
				# moves the lich to a distance of 15 to the player
				## has to use get_speed() to move based on dusted effect
				var collision = move_and_collide(current_move_direction * get_speed())
				if collision != null:
					direction_change_timer.stop()
					random_direction(true)
				
				# attacks
				# checks to see if the player can fire
				if time_to_fire <= 0:
					# checks to see which direction is the click was 
					var blade_instance = ENEMY_KNIFE.instantiate()
					# spawns a knife at that position
					blade_instance.position = position + target_position*3
					blade_instance.spawned(target_position, dust_blade)
					get_parent().add_child(blade_instance)
					# plays the knife throw sound when the blade is spawned
					woosh_sound.play()
					
					# if the player has triple blades, spawn the two other blades
					if triple_blades == true:
						# bottom blade
						var radians = target_position.angle()
						var rad_added_bottom = Vector2(cos(radians + 0.25), sin(radians + 0.25))
						rad_added_bottom = rad_added_bottom.normalized()
						var blade_instance_2 = ENEMY_KNIFE.instantiate()
						blade_instance_2.position = position + rad_added_bottom*3
						blade_instance_2.spawned(rad_added_bottom)
						get_parent().add_child(blade_instance_2)
						# top blade
						var rad_added_top = Vector2(cos(radians - 0.25), sin(radians - 0.25))
						rad_added_top = rad_added_top.normalized()
						var blade_instance_3 = ENEMY_KNIFE.instantiate()
						blade_instance_3.position = position + rad_added_top*3
						blade_instance_3.spawned(rad_added_top)
						get_parent().add_child(blade_instance_3)
					# resets the time to fire
					time_to_fire = time_to_fire_max

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	# checks if the enemy is spawning or dying
	if !spawning && !dying:
		# deals the damage to the enemy
		health -= damage
		# plays the hit sound if the HP after damage is > 0
		if health > 0:
			# plays the hit sound
			hit_sound.play()
			animated_sprite.material.shader = null
			animated_sprite.material.shader = PLAYER_SHADER
			hit_sound.play()
			hit_flash_animation_player.play("hit_flash")
			hit_flash_animation_timer.start()
		# checks if the enemy should be dead
		elif health <= 0:
			# sets the enemy's state to dying
			dying = true
			# starts the death animation timer
			death_timer.start()
			# plays the death animation
			animated_sprite.play("dying")
			# plays the death sound
			death_sound.play()
			# spawn_sound is the portal sound
			spawn_sound.play()
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.morphed_shade)
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the lich state to spawning
	spawning = true
	# play spawning animation
	animated_sprite.play("spawning")
	# start the spawn timer
	spawn_timer.start()
	# play the spawn sound
	spawn_sound.play()

# when the spawn timer ends
func _on_spawn_timer_timeout():
	# the state is no longer spawning
	spawning = false
	# show the lich's health bar in the HUD
	hud.set_health_bar(max_health, "You?")
	
	current_move_direction = Vector2(0, -1)
	direction_change_timer.start(0.2)

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the lich to attack
	can_attack = true

func _on_direction_change_timer_timeout():
	random_direction(false)

func random_direction(hit_object : bool):
	var vector_normalized = current_direction
	if hit_object:
		var vec_x = rng.randf_range(0, 1)
		var pos_or_neg = rng.randi_range(-1, 1)
		if current_move_direction.x < 0:
			pos_or_neg = rng.randi_range(0, 1)
		if current_move_direction.x > 0:
			pos_or_neg = rng.randi_range(-1, 0)
		vec_x = pos_or_neg * vec_x
		var vec_y = rng.randf_range(0, 1)
		pos_or_neg = rng.randi_range(-1, 1)
		if current_move_direction.y < 0:
			pos_or_neg = rng.randi_range(0, 1)
		if current_move_direction.y > 0:
			pos_or_neg = rng.randi_range(-1, 0)
		vec_y = pos_or_neg * vec_y
		vector_normalized = Vector2(vec_x, vec_y).normalized()
		current_move_direction = vector_normalized
	else:
		var vec_x = rng.randf_range(0, 1)
		var pos_or_neg = rng.randi_range(-1, 1)
		vec_x = pos_or_neg * vec_x
		var vec_y = rng.randf_range(0, 1)
		pos_or_neg = rng.randi_range(-1, 1)
		vec_y = pos_or_neg * vec_y
		vector_normalized = Vector2(vec_x, vec_y).normalized()
		current_move_direction = vector_normalized
	
	var duration = rng.randf_range(0.1, 10)
	if vector_normalized == Vector2(0, 0):
		duration = rng.randf_range(0.1, 3)
	direction_change_timer.start(duration)
	print(vector_normalized)
	print(duration)

# calculate the attack speed
func calculate_attack_speed():
	time_to_fire_max = time_to_fire_max / attacks_per_second

# load the player data from previous floors
func load_player_data():
	# recollect the items obtained
	for item in PlayerData.items_collected:
		if item == ItemType.type.triple_blades:
			triple_blades = true
		elif item == ItemType.type.quick_blades:
			# increase attack speed
			attacks_per_second += 1
		elif item == ItemType.type.speed_boots:
			# increase the player's speed
			speed += 15
		elif item == ItemType.type.dust_blade:
			# add dust blades to the player
			dust_blade = true
	calculate_attack_speed()

func _on_hit_flash_animation_timer_timeout():
	animated_sprite.material.shader = null
