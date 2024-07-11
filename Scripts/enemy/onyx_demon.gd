extends Enemy

enum state
{
	attacking,
	idle,
}

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var hud = %HUD
@onready var spawn_timer = $Spawn_timer
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")
const ONYX_HAND_ITEM = preload("res://Scenes/items/onyx_hand_item.tscn")

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_sound_timer = $Spawn_sound_timer
const ONYX_DEMON_DEATH = preload("res://Scenes/enemies/void_orb/onyx_demon_death.tscn")
@onready var attack_sound = $attack_sound

# attack variables
@onready var attack_animation_timer = $attack_animation_timer
var void_orb_spawns = 0
@onready var void_orb_spawn_timer = $void_orb_spawn_timer
@onready var void_orb_spawn_interval = $void_orb_spawn_interval
const VOID_ORB = preload("res://Scenes/enemies/void_orb/void_orb.tscn")

# basic enemy variables
var target_position
var current_direction : look_direction
var can_attack = false
var can_move = true
var current_state = state.idle

# on start
func _ready():
	# basic enemy stats
	speed = 0.0
	health = 75
	max_health = health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()

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
			player_position = player.get_player_position()
			target_position = (player_position - animated_sprite.global_position).normalized()
			# if the golem can attack
			if can_attack:
				# do a random attack
				attack()
			elif current_state == state.idle:
				current_direction = get_left_right_look_direction(target_position)
				# flips the direction of the golem based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("idle_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("idle_right")
				
				### NOTE: the golem cannot move currently but this is here just in case this is changes
				## moves the golem to a distance of 15 to the player
				#if position.distance_to(player_position) > 15:
					### has to use get_speed() to move based on dusted effect
					#move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage, attack_identifer, is_effect):
	var attack_can_hit = true
	#if the damage is not an effect
	if is_effect == false:
		# checks if an attack with the identifier has hit
		for identifier in attacks_that_hit:
			if identifier == attack_identifer:
				attack_can_hit = false
	# checks if the enemy is spawning or dying
	if spawning || dying:
		attack_can_hit = false
	# if the attack can hit
	if attack_can_hit:
		# adds the attack to the attacks that have hit
		attacks_that_hit += [attack_identifer]
		# deals the damage to the enemy
		health -= damage
		# add the damage to the player's stats
		PlayerData.damage_dealt += damage
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)
		# plays the hit sound if the HP after damage is > 0
		if health > 0:
			# plays the hit animation
			animated_sprite.material.shader = null
			animated_sprite.material.shader = ENEMY_HIT_SHADER
			hit_flash_animation_player.play("hit_flash")
			hit_flash_animation_timer.start()
			# plays the hit sound
			hit_sound.play()
		# checks if the enemy should be dead
		elif health <= 0:
			# sets the enemy's state to dying
			dying = true
			# starts the death animation timer
			death_timer.start()
			# plays the death animation
			animated_sprite.play("dying")
			# plays the death sound
			var death_sound = ONYX_DEMON_DEATH.instantiate()
			get_parent().add_child(death_sound)
			death_sound.global_position = animated_sprite.global_position
			death_sound.spawned()
			# remove the damage player hitbox
			damage_player.queue_free()
			remove_hitbox()

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.onyx_demon)
	# spawn the item for the mini boss the mini boss dies
	var item = ONYX_HAND_ITEM.instantiate()
	get_parent().add_child(item)
	item.global_position = animated_sprite.global_position
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

# when the spawn timer ends
func _on_spawn_timer_timeout():
	# the state is no longer spawning
	spawning = false
	# show the golem's health bar in the HUD
	hud.set_health_bar(max_health, "Onyx Demon")

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the golem to attack
	can_attack = true

# when the golem is doing a random attack
func attack():
	# checks to make sure the character isn't dying
	if !dying:
		if current_direction == look_direction.right:
			animated_sprite.play("attack_right")
		if current_direction == look_direction.left:
			animated_sprite.play("attack_left")
		void_orb_spawn_timer.start()
		can_attack = false
		current_state = state.attacking

# when the attacks end
func attack_end():
	current_state = state.idle
	attack_timer.start()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

func _on_attack_animation_timer_timeout():
	attack_end()

func spawn_void_orb():
	if !dying:
		attack_sound.play()
		# get the player's position
		player_position = player.get_player_position()
		var projectile_direction = (player_position - animated_sprite.global_position).normalized()
		# create and spawn the void_orb to move toward the player's direction
		var void_orb = VOID_ORB.instantiate()
		get_tree().current_scene.add_child(void_orb)
		void_orb.global_position = animated_sprite.global_position
		void_orb.spawned(projectile_direction, true, true)
		void_orb_spawns += 1
		
		if void_orb_spawns == 3:
			if animated_sprite.animation == "attack_left":
				animated_sprite.play("attack_left_end")
			if animated_sprite.animation == "attack_right":
				animated_sprite.play("attack_right_end")
			attack_animation_timer.start()
			void_orb_spawns = 0
		else:
			void_orb_spawn_interval.start()

func _on_void_orb_spawn_timer_timeout():
	# checks to make sure the character isn't dying
	spawn_void_orb()

func _on_void_orb_spawn_interval_timeout():
	spawn_void_orb()
