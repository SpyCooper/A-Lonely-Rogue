extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var spawn_timer = $Spawn_timer
@onready var hud = %HUD
@onready var hit_animation_timer = $AnimatedSprite2D/hit_animation_timer

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound
@onready var spawn_sound_timer = $Spawn_sound_timer

# spawn skeletons attack variables
@onready var spawn_skeletons_anim_timer = $spawn_skeletons_anim_timer
@onready var skeleton_spawn_left_location = $skeleton_spawn_left_location
@onready var lightning_left = $skeleton_spawn_left_location/lightning_left
@onready var skeleton_spawn_right_location = $skeleton_spawn_right_location
@onready var lightning_right = $skeleton_spawn_right_location/lightning_right
@onready var lightning_timer = $lightning_timer
@onready var delay_lighning_timer = $delay_lighning_timer
const SKELETON_ARCHER = preload("res://Scenes/enemies/skeleton_archer.tscn")
const SKELETON_MAGE = preload("res://Scenes/enemies/skeleton_mage.tscn")
const SKELETON_WARRIOR = preload("res://Scenes/enemies/skeleton_warrior.tscn")

# shadow ball attack references
@onready var shadow_ball_anim_timer = $shadow_ball_anim_timer
@onready var shadow_ball_spawn_right = $Shadow_ball_spawn_right
@onready var shadow_ball_spawn_left = $Shadow_ball_spawn_left
@onready var shadow_ball_spawn_timer = $shadow_ball_spawn_timer
const SHADOW_BALL = preload("res://Scenes/enemies/shadow_bolt/shadow_ball.tscn")

# poison area attack references
const POISON_AREA = preload("res://Scenes/enemies/poison_area/poison_area.tscn")
@onready var summon_poison_anim_timer = $"summon poison_anim_timer"
@onready var summon_poison_spawn_timer = $"summon poison_spawn_timer"
@onready var delay_player_pos_timer = $delay_player_pos_timer
var temp_player_pos

# heal attack variables
@onready var heal_animation_timer = $heal_animation_timer
const SKELETON_UNARMED = preload("res://Scenes/enemies/skeleton_unarmed.tscn")
@onready var summon_one_lighning_timer = $summon_one_lighning_timer
@onready var lighning_duration_heal_timer = $lighning_duration_heal_timer
@onready var time_before_heal_timer = $time_before_heal_timer
var unarmed_skeleton
var heal_amount = 15
const LIGHTNING = preload("res://Scenes/enemies/lightning/lightning.tscn")
var temp_lightning
@onready var temp_lightning_timer = $temp_lightning_timer

# defines a random number generator
var rng = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var playing_hit_animation = false
var can_attack = false
var can_move = true

# on start
func _ready():
	# basic enemy stats
	speed = 0.0
	max_health = 70
	health = max_health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()
	
	hide_lightning()

# defines the wake_up function needed for the golem
## this is called by the rooms when a player enters it
func wake_up():
	player_in_room = true
	# runs spawn_in()
	spawn_in()
	# starts the attack timer
	attack_timer.start()

# called every frame
func _physics_process(_delta):
	# if the player is in the room, not dying, and not spawning
	if player_in_room && !dying && !spawning:
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the golem can attack
			if can_attack:
				# do a random attack
				random_attack()
			# if the enemy can move (cannot move when attacking)
			elif can_move:
				# flips the direction of the golem based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# if any of the hit animations are playing
					if animated_sprite.animation == "hit_right":
						# switch to the same frame of the hit animation in the new direction
						# this keeps hit animations running for the same duration
						var frame = animated_sprite.frame
						animated_sprite.play("hit_left")
						animated_sprite.frame = frame
					# if a hit animation is not actively playing a hit animation
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						# plays the basic move animation and sets the playing_hit_animation to false
						animated_sprite.play("move_left")
						playing_hit_animation = false
				## Move right
				elif current_direction == look_direction.right:
					if animated_sprite.animation == "hit_left":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_right")
						animated_sprite.frame = frame
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						animated_sprite.play("move_right")
						playing_hit_animation = false
				## NOTE: the golem cannot move currently but this is here just in case this is changes
				# moves the golem to a distance of 15 to the player
				if position.distance_to(player_position) > 15:
					## has to use get_speed() to move based on dusted effect
					move_and_collide(target_position.normalized() * get_speed())

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
			# if the golem can move (i.e. not attacking)
			if can_move:
				# plays the hit animation based on the current direction
				if current_direction == look_direction.left:
					var frame = animated_sprite.frame
					animated_sprite.play("hit_left")
					animated_sprite.frame = frame
				elif current_direction == look_direction.right:
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame
				# sets the playing_hit_animation
				playing_hit_animation = true
				
				hit_animation_timer.start()
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
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)

func _on_hit_animation_timer_timeout():
	if current_direction == look_direction.left && animated_sprite.animation == "hit_left":
		var frame = animated_sprite.frame
		animated_sprite.play("move_left")
		animated_sprite.frame = frame
	elif current_direction == look_direction.right && animated_sprite.animation == "hit_right":
		var frame = animated_sprite.frame
		animated_sprite.play("move_right")
		animated_sprite.frame = frame
	# sets the playing_hit_animation
	playing_hit_animation = false

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.lich)
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the golem state to spawning
	spawning = true
	# play spawning animation
	animated_sprite.play("spawning")
	# start the spawn timer
	spawn_timer.start()
	# play the spawn sound
	spawn_sound.play()
	
	# the state is no longer spawning
	spawning = false
	# show the golem's health bar in the HUD
	hud.set_health_bar(max_health, "Lich")

# when the spawn timer ends
func _on_spawn_timer_timeout():
	## the state is no longer spawning
	#spawning = false
	## show the golem's health bar in the HUD
	#hud.set_health_bar(max_health, "Lich")
	pass

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the golem to attack
	can_attack = true

# when the golem is doing a random attack
func random_attack():
	# set bools for attacking
	can_move = false
	can_attack = false
	# does a random attack
	var random_number = rng.randi_range(0, 10)
	if random_number <= 2:
		shadow_ball_attack()
	elif random_number <= 5:
		spawn_skeletons_attack()
	elif random_number <= 8:
		summon_poison()
	else:
		heal_attack()

# when the attacks end
func attack_end():
	# allow the golem to move
	can_move = true
	# start the attack timer
	attack_timer.start()

func spawn_skeletons_attack():
	spawn_skeletons_anim_timer.start()
	if current_direction == look_direction.left:
		animated_sprite.play("spawn_skeletons_left")
	elif current_direction == look_direction.right:
		animated_sprite.play("spawn_skeletons_right")
	
	delay_lighning_timer.start()

func _on_spawn_skeletons_anim_timer_timeout():
	attack_end()

func _on_delay_lighning_timer_timeout():
	lightning_left.show()
	lightning_right.show()
	lightning_timer.start()

func _on_lightning_timer_timeout():
	hide_lightning()
	spawn_skeletons()

func hide_lightning():
	lightning_left.hide()
	lightning_right.hide()

func spawn_skeletons():
	for n in [1, 2]:
		var random_number = rng.randi_range(1, 3)
		var random_skel = SKELETON_WARRIOR
		if random_number == 1:
			random_skel = SKELETON_ARCHER
		elif random_number == 2:
			random_skel = SKELETON_MAGE
		elif random_number == 3:
			random_skel = SKELETON_WARRIOR
		# set the correct laser spawn location
		var spawn_location
		if n == 1:
			spawn_location = skeleton_spawn_left_location
		elif n == 2:
			spawn_location = skeleton_spawn_right_location
		# spawn the laser
		var skel = random_skel.instantiate()
		get_parent().add_child(skel)
		skel.spawned_in_room()
		# set the laser's position
		skel.global_position = spawn_location.global_position
		# tell the laser that it's spawned

func shadow_ball_attack():
	if current_direction == look_direction.right:
		animated_sprite.play("shadow_ball_right")
	elif current_direction == look_direction.left:
		animated_sprite.play("shadow_ball_left")
	shadow_ball_anim_timer.start()
	shadow_ball_spawn_timer.start()

func _on_shadow_ball_anim_timer_timeout():
	attack_end()

func spawn_shadow_ball():
	var spawn_location = shadow_ball_spawn_right
	if current_direction == look_direction.left:
		spawn_location = shadow_ball_spawn_left
	
	var shadow_ball = SHADOW_BALL.instantiate()
	shadow_ball.global_position = spawn_location.global_position
	get_parent().add_child(shadow_ball)
	# tell the shadow ball that it spawned
	shadow_ball.spawned()

func _on_shadow_ball_spawn_timer_timeout():
	spawn_shadow_ball()

func summon_poison():
	if current_direction == look_direction.right:
		animated_sprite.play("shadow_ball_right")
	elif current_direction == look_direction.left:
		animated_sprite.play("shadow_ball_left")
	temp_player_pos = player.global_position
	summon_poison_anim_timer.start()
	summon_poison_spawn_timer.start()
	delay_player_pos_timer.start()

func _on_summon_poison_anim_timer_timeout():
	attack_end()

func _on_summon_poison_spawn_timer_timeout():
	# spawn the vine area
	var poison_area = POISON_AREA.instantiate()
	get_parent().add_child(poison_area)
	# tell the vine area that it's spawned
	poison_area.spawned(temp_player_pos)

func _on_delay_player_pos_timer_timeout():
	temp_player_pos = player.global_position

func heal_attack():
	heal_animation_timer.start()
	if current_direction == look_direction.left:
		animated_sprite.play("heal_start_left")
	elif current_direction == look_direction.right:
		animated_sprite.play("heal_start_right")
	summon_one_lighning_timer.start()

func _on_summon_one_lighning_timer_timeout():
	if current_direction == look_direction.left:
		lightning_left.show()
		animated_sprite.play("heal_idle_left")
	else:
		lightning_right.show()
		animated_sprite.play("heal_idle_right")
	lighning_duration_heal_timer.start()

func _on_lighning_duration_heal_timer_timeout():
	hide_lightning()
	spawn_unarmed_skeleton()

func spawn_unarmed_skeleton():
	# set the correct laser spawn location
	var spawn_location = skeleton_spawn_right_location
	if current_direction == look_direction.left:
		spawn_location = skeleton_spawn_left_location
	# spawn the laser
	var skel = SKELETON_UNARMED.instantiate()
	get_parent().add_child(skel)
	skel.spawned_in_room()
	# set the laser's position
	skel.global_position = spawn_location.global_position
	
	unarmed_skeleton = skel
	
	time_before_heal_timer.start()

func _on_time_before_heal_timer_timeout():
	if unarmed_skeleton != null:
		temp_lightning = LIGHTNING.instantiate()
		add_child(temp_lightning)
		temp_lightning.global_position = unarmed_skeleton.global_position + Vector2(0, -125)
		temp_lightning_timer.start()
		unarmed_skeleton.despawn()
		heal()
		if current_direction == look_direction.right:
			animated_sprite.play("heal_end_success_right")
		else:
			animated_sprite.play("heal_end_success_left")
	else:
		if current_direction == look_direction.right:
			animated_sprite.play("heal_end_fail_right")
		else:
			animated_sprite.play("heal_end_fail_left")
		

func heal():
	if health + heal_amount > max_health:
		health = max_health
	else:
		health += heal_amount
	# adjust the boss health bar in the HUD
	hud.adjust_health_bar(health)

func _on_heal_animation_timer_timeout():
	attack_end()

func _on_temp_lightning_timer_timeout():
	temp_lightning.queue_free()
