extends CharacterBody2D

class_name Player

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $DeathTimer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hud = %HUD
@onready var hit_sound = $hit_sound
@onready var item_pickup_sound = $item_pickup_sound
@onready var unlock_door_sound = $Unlock_door_sound
@onready var woosh_sound = $woosh_sound
@onready var item_break_sound = $item_break_sound
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const HIT_SHADER = preload("res://Scripts/shaders/hit_shader.tres")

# references related to the falling animation at the start of each floor
@onready var fall_timer = $fall_timer
@onready var falling_shadow_sprite = $falling_shadow_sprite
@onready var stand_up_sprite = $stand_up_sprite
@onready var stand_up_timer = $stand_up_timer
@onready var falling_sprite = $falling_sprite
@onready var falling_animation_player = $falling_sprite/falling_AnimationPlayer
@onready var player_fall_sound = $player_fall_sound
@onready var player_fall_sound_timer = $player_fall_sound/player_fall_sound_timer
@onready var falling_sprite_dark = $falling_sprite_dark
@onready var falling_dark_animation_player = $falling_sprite_dark/falling_dark_AnimationPlayer

# constants
const KNIFE_SPEED = 150.0
const PLAYER_HEALTH_MAX = 10

# variables
var lastMove = "default"
var attacks_per_second = 1
var attack_damage = 1
var current_attack_identifier : int
var time_to_fire = 0.0
var time_to_fire_max = 1.0
var player_health = 6
var speed = 100.0
var number_of_keys = 0
var dying = false
var player_can_move = false
var slow_percentage = 0.0
var dusted = false
var dusted_stack = 0
var dusted_slow = 0.35
var attacks_that_have_hit = []

# knife variables
var poisoned_blade = false
var shadow_blade = false
var glass_blade = false
var shadow_flame_blade = false
var dust_blade = false
var triple_blades = false
var sleek_blade = false
var knife_speed_bonus = 0
var current_type : BladeType.blade_type = BladeType.blade_type.default
var knife_scene = load("res://Scenes/knife.tscn")

# passive item variables
var shadow_heart = false
var shadow_heart_heal_counter = 0
var shadow_heart_collected = false
var poorly_made_voodoo_doll = false
var can_poorly_made_voodoo_doll_be_spawned = true
@onready var burning_sound = $burning_sound
@onready var voodoo_doll_immunity_timer = $voodoo_doll_immunity_timer
var immunity = false
var items_collected = []

# pet variables
var current_pet = null
var current_pet_item = ItemType.type.temp
const PROTECTIVE_CHARM_SPAWN = preload("res://Scenes/pets/protective_charm_spawn.tscn")
const HURTFUL_CHARM_SPAWN = preload("res://Scenes/pets/hurtful_charm_spawn.tscn")
const DANGLING_ROGUE = preload("res://Scenes/pets/dangling_rogue.tscn")
const DEAD_ROGUE = preload("res://Scenes/pets/dead_rogue.tscn")

# usable item variables
var use_item_cooldown = 3.0
var usable_item_stack_amount = 0
@onready var usable_item_cooldown_timer = $Usable_Item_cooldown_timer
var can_use_item = true
var current_usable_item = ItemType.type.temp

# usable item effects
const PLAYER_FRIENDLY_POISON_AREA = preload("res://Scenes/player/player_friendly_poison_area.tscn")
const TINY_ROGUE = preload("res://Scenes/pets/tiny_rogue.tscn")
const BOMB = preload("res://Scenes/bomb.tscn")

# dash boots variables
@onready var dash_timer = $Dash_timer
var dash_speed_boost = 150.0
var is_dashing = false
const PLAYER_AFTER_IMAGE = preload("res://Scenes/player/player_after_image.tscn")
@onready var after_image_spawn_timer = $after_image_spawn_timer
var after_images = 0

## ------------------- basic node functions ----------------------------------------------------------------

# runs on start
func _ready():
	# sets the stats for the player
	attacks_per_second = 1
	time_to_fire_max = time_to_fire_max / attacks_per_second
	current_attack_identifier = 0
	# load the player data, if there is any
	# used to transfer data between floor
	load_player_data()
	Events.player = self
	# plays the fall animation
	player_can_move = false
	# starts the falling animation
	animated_sprite.hide()
	falling_shadow_sprite.show()
	falling_shadow_sprite.play("default")
	if shadow_heart:
		falling_sprite.hide()
		falling_sprite_dark.show()
		falling_dark_animation_player.play("player_falling")
	else:
		falling_sprite.show()
		falling_sprite_dark.hide()
		falling_animation_player.play("player_falling")
	stand_up_sprite.hide()
	# if the current floor is 1, hide hud during fall
	if get_tree().current_scene.name == "Floor1":
		hud.hide()
	# refresh the hud
	hud.refresh_key_amount(number_of_keys)
	hud.refresh_hearts(player_health, shadow_heart)
	# start the fall timers
	fall_timer.start()
	player_fall_sound_timer.start()

# runs on every frame
func _process(delta):
	# if the time to fire is above 0, it reduces the timer
	if time_to_fire > 0:
		time_to_fire -= delta

# runs on a set interval (fixed_update)
func _physics_process(_delta):
	# if the player is not dying and can move
	if !dying && player_can_move:
		# controls player movement and normalizes the vector
		var direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
		direction.normalized()
		velocity = direction * get_speed()
		# controls the animations for the movement
		if direction.y == -1:
			if shadow_heart:
				animated_sprite.play("move_up_dark")
			else:
				animated_sprite.play("move_up")
			lastMove = "move_up"
		elif direction.y == 1:
			if shadow_heart:
				animated_sprite.play("move_down_dark")
			else:
				animated_sprite.play("move_down")
			lastMove = "move_down"
		elif direction.x < 0:
			if shadow_heart:
				animated_sprite.play("move_left_dark")
			else:
				animated_sprite.play("move_left")
			lastMove = "move_left"
		elif direction.x > 0:
			if shadow_heart:
				animated_sprite.play("move_right_dark")
			else:
				animated_sprite.play("move_right")
			lastMove = "move_right"
		else:
			# sets the idle animations based on the last movemnet
			if lastMove == "move_right":
				if shadow_heart:
					animated_sprite.play("idle_right_dark")
				else:
					animated_sprite.play("idle_right")
			elif lastMove == "move_left":
				if shadow_heart:
					animated_sprite.play("idle_left_dark")
				else:
					animated_sprite.play("idle_left")
			elif lastMove == "move_up":
				if shadow_heart:
					animated_sprite.play("idle_up_dark")
				else:
					animated_sprite.play("idle_up")
			else:
				if shadow_heart:
					animated_sprite.play("idle_down_dark")
				else:
					animated_sprite.play("idle_down")
		# moves the player
		move_and_slide()
		# controls throwing knives
		if Input.is_action_pressed("Attack"):
			# checks to see if the player can fire
			if time_to_fire <= 0:
				# checks to see which direction is the click was 
				var click_position = get_global_mouse_position() - position
				var click_position_normalized = click_position.normalized()
				var blade_instance = knife_scene.instantiate()
				# spawns a knife at that position
				blade_instance.position = position + click_position_normalized*3
				blade_instance.spawned(click_position_normalized, current_type, self, current_attack_identifier, knife_speed_bonus)
				get_parent().add_child(blade_instance)
				# plays the knife throw sound when the blade is spawned
				woosh_sound.play()
				# if the player has triple blades, spawn the two other blades
				if triple_blades == true:
					# bottom blade
					var radians = click_position_normalized.angle()
					var rad_added_bottom = Vector2(cos(radians + 0.25), sin(radians + 0.25))
					rad_added_bottom = rad_added_bottom.normalized()
					var blade_instance_2 = knife_scene.instantiate()
					blade_instance_2.position = position + rad_added_bottom*3
					blade_instance_2.spawned(rad_added_bottom, current_type, self, current_attack_identifier, knife_speed_bonus)
					get_parent().add_child(blade_instance_2)
					# top blade
					var rad_added_top = Vector2(cos(radians - 0.25), sin(radians - 0.25))
					rad_added_top = rad_added_top.normalized()
					var blade_instance_3 = knife_scene.instantiate()
					blade_instance_3.position = position + rad_added_top*3
					blade_instance_3.spawned(rad_added_top, current_type, self, current_attack_identifier, knife_speed_bonus)
					get_parent().add_child(blade_instance_3)
				# resets the time to fire
				time_to_fire = time_to_fire_max
				# increments the attack identifier
				current_attack_identifier = current_attack_identifier + 1
		# if use item is pressed
		if Input.is_action_pressed("UseItem") && can_use_item:
			# use a usable item
			use_usable_item()


## ------------------- falling animation functions ------------------------------------------------------------

# when the fall timer ends
func _on_fall_timer_timeout():
	# hide the fall and fall shadow sprites
	falling_shadow_sprite.hide()
	if shadow_heart:
		falling_sprite_dark.hide()
	else:
		falling_sprite.hide()
	# play the stand up animation
	stand_up_sprite.show()
	if shadow_heart:
		stand_up_sprite.play("stand_up_dark")
	else:
		stand_up_sprite.play("stand_up")
	# start the stand up timer
	stand_up_timer.start()

# when the stand up timer ends
func _on_stand_up_timer_timeout():
	# show the normal animated sprite
	animated_sprite.show()
	# if the player has a shadow_heart, change the sprite
	if shadow_heart:
		animated_sprite.play("idle_down_dark")
	# hide the stand up music
	stand_up_sprite.hide()
	# play the backgound music for the floor
	get_parent().play_bg_music()
	# allow the player to move
	player_can_move = true
	# show the hud
	hud.show()
	# show the floor text
	if get_tree().current_scene.name == "Floor1":
		hud.show_starting_text()
	elif get_tree().current_scene.name == "Floor2":
		hud.display_text("Floor 2", "There shouldn't not be any more slimes, right?")
	elif get_tree().current_scene.name == "Floor3":
		hud.display_text("Floor 3", "Sound like the dead here...")
	elif get_tree().current_scene.name == "Floor4":
		hud.display_text("Floor 4", "Did that shadow just move?")
	elif get_tree().current_scene.name == "Floor5":
		hud.display_text("Floor 5", "Time to get out of here...")

# when the player fall sound timer ends, play the fall sound
func _on_player_fall_sound_timer_timeout():
	player_fall_sound.play()


## ------------------- PlayerData functions ------------------------------------------------------------

# save the player data to transfer between floors
func save_player_data():
	PlayerData.clear_data()
	PlayerData.player_health = player_health
	PlayerData.number_of_keys = number_of_keys
	PlayerData.items_collected = items_collected
	# save the pet data
	if current_pet != null:
		PlayerData.current_pet_health = current_pet.health

# load the player data from previous floors
func load_player_data():
	player_health = PlayerData.player_health
	number_of_keys = PlayerData.number_of_keys
	# recollect the items obtained
	var temp_items_collected = PlayerData.items_collected
	for item in temp_items_collected:
		# does not allow a player to load into a floor with a hurtful charm
		if item != ItemType.type.hurtful_charm:
			# pick up item
			picked_up_item(item, false, false)
			# check if it can be spawned again
			var can_be_spawned_again = false
			for type in ItemType.repeatable_items:
				if item == type:
					can_be_spawned_again = true
			# if the item cannot be spawned again, do not let it spawn
			if !can_be_spawned_again:
				ItemType.add_spawned_item(item)
		# destroys the hurtful charm item
		else:
			item_break_sound.play()
	# refresh the HUD
	hud.refresh_hearts(player_health)
	hud.refresh_key_amount(number_of_keys)
	# load the pet data
	if current_pet != null:
		current_pet.set_pet_hp(PlayerData.current_pet_health)


## ------------------- combat functions ----------------------------------------------------------------

# calculate the attack speed
func calculate_attack_speed():
	time_to_fire_max = time_to_fire_max / attacks_per_second

# returns the current weapons
func get_current_weapons():
	var current_blades = []
	if sleek_blade == true:
		current_blades += [BladeType.blade_type.sleek]
	if poisoned_blade == true:
		current_blades += [BladeType.blade_type.posioned]
	if shadow_flame_blade == true:
		current_blades += [BladeType.blade_type.shadow_flame]
	if dust_blade == true:
		current_blades += [BladeType.blade_type.dust]
	if shadow_blade == true:
		current_blades += [BladeType.blade_type.shadow]
	if glass_blade == true:
		current_blades += [BladeType.blade_type.glass]
	return current_blades

# if the enemy is killed
func killed_enemy():
	# if the shadow heart is active, increase health by 1
	if shadow_heart == true:
		shadow_heart_heal_counter += 1
		if shadow_heart_heal_counter == 3:
			shadow_heart_heal_counter = 0
			player_adjust_health(1)

# returns the speed
func get_speed():
	# if the player is dashing
	if is_dashing:
		# add the dashing speed to the movement speed
		return speed * (1.0 - slow_percentage) + dash_speed_boost
	else:
		return speed * (1.0 - slow_percentage)

# applies the slow
func apply_slow(slow_perc):
	slow_percentage += slow_perc

# removes a slow
func remove_slow(slow_perc):
	slow_percentage -= slow_perc

# sets the dusted status
func set_dusted_status(status):
	if status == true:
		dusted_stack += 1
		dusted = true
		# if this is the first dusted stack
		if dusted_stack == 1:
			# apply the dustes slow
			apply_slow(dusted_slow)
	else:
		dusted_stack -= 1
	# if all dusted stacks are gone, the player is no longer dusted
	if dusted_stack == 0:
		dusted = false
		remove_slow(dusted_slow)

# returns if the player is has dust_blade effect on them
func is_dusted():
	return dusted


## ------------------- health functions ----------------------------------------------------------------

# runs when an enemy hits the player
func player_take_damage(is_ms_knife, attack_identifer):
	# checks if the attack can hit (used for the morphed shade fight
	var can_hit = true
	# if the player is dying, attacks cannot hit
	if dying:
		can_hit = false
	# if the attack is a morphed shade knife
	if is_ms_knife && can_hit:
		# checks if the knife can hit
		for attack in attacks_that_have_hit:
			if attack_identifer == attack:
				can_hit = false
		if can_hit:
			attacks_that_have_hit += [attack_identifer]
	# if the player is not dying
	if can_hit:
		# get hit
		player_adjust_health(-1)
		# plays the hit flash animation
		animated_sprite.material.shader = null
		animated_sprite.material.shader = HIT_SHADER
		hit_sound.play()
		hit_flash_animation_player.play("hit_flash")
		hit_flash_animation_timer.start()

# adjust player's health
# used to heal and take damage
func player_adjust_health(change : int):
	if !immunity:
		# if the change will put the the player's health above the max, set to the max
		if(player_health + change > PLAYER_HEALTH_MAX):
			player_health = PLAYER_HEALTH_MAX
		# else, add the change
		else:
			player_health += change
		# refresh the hearts for the player
		hud.refresh_hearts(player_health, shadow_heart)
		# if health is <= 0
		if player_health <= 0:
			# if the player has a poorly made voodoo doll
			if poorly_made_voodoo_doll:
				# set the poorly made voodoo doll to false
				poorly_made_voodoo_doll = false
				# set player hp to 1
				player_health = 1
				# refresh the hug
				hud.refresh_hearts(player_health, shadow_heart)
				# play the burning sound
				burning_sound.play()
				# set immunity to true
				immunity = true
				# start the doll immunity timer
				voodoo_doll_immunity_timer.start()
				# light the poorly made voodoo doll on fire
				hud.play_poorly_made_voodoo_doll_fire()
			# if the player does not have a poorly made voodoo doll
			else:
				# set the time scale to .5
				Engine.time_scale = 0.5
				# set state to dying
				dying = true
				# start death timer
				death_timer.start()
				# play the death animation
				if shadow_heart:
					animated_sprite.play("death_dark")
				else:
					animated_sprite.play("death")

# when the hit flash aniamtion timer ends
func _on_hit_flash_animation_timer_timeout():
	animated_sprite.material.shader = null

# return if the player is dying
func get_is_dying():
	return dying

# when the death_timer runs out, the scene resets
func _on_death_timer_timeout():
	Engine.time_scale = 1
	PlayerData.clear_data()
	get_tree().change_scene_to_file("res://Scenes/Dungeon_floors/dungeon_floor_1.tscn")


## ------------------- general item functions ----------------------------------------------------------------

# runs when an item is picked up
func picked_up_item(item, display_text = true, sound = true):
	# unlock the item in the catalog
	Events.catalog.unlock_item(item)
	# if sound is allowed, play tthe sound
	if sound:
		item_pickup_sound.play()
	# there is probably a better way to do this but this will work for now
	# check the enum in item.gd for the numbers
	# for each item, add it's effect
	if item == ItemType.type.temp:
		pass
	elif item == ItemType.type.health_2:
		# if the player does not have shadow heart, add HP
		if shadow_heart == false:
			player_adjust_health(2)
	elif item == ItemType.type.health_1:
		# if the player does not have shadow heart, add HP
		if shadow_heart == false:
			player_adjust_health(1)
	elif item == ItemType.type.poisoned_blades:
		# display the item text
		if display_text:
			hud.display_text("Aquired Poisoned Blades!", "Blades damage enemies after a short time for light damage.")
		# add the poison blade to the player
		poisoned_blade = true
		# set current blade to poisoned
		current_type = BladeType.blade_type.posioned
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.speed_boots:
		# increase the player's speed
		speed += ItemType.speed_boots_movement_speed_bonus
		# display the item text
		if display_text:
			hud.display_text("Aquired Speed Boots!", "You run faster.")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.quick_blades:
		# increase attack speed
		attacks_per_second += ItemType.quick_blades_attack_speed_bonus
		#recalculate the attack_speed()
		calculate_attack_speed()
		# display the item text
		if display_text:
			hud.display_text("Aquired Quicker Blades!", "Blades can be thrown faster.")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.shadow_flame:
		# add the shadow flame blade to the player
		shadow_flame_blade = true
		# set current blade to shadow flame
		current_type = BladeType.blade_type.shadow_flame
		# display the item text
		if display_text:
			hud.display_text("Aquired Shadowflame!", "Blades damage enemies after a time for moderate damage.")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.shadow_blade:
		# add the shadow blade to the player
		shadow_blade = true
		# set current blade to shadow
		current_type = BladeType.blade_type.shadow
		# display the item text
		if display_text:
			hud.display_text("Aquired Shadow Blades!", "Blades do increased damage.")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.key:
		# increase the number of keys
		number_of_keys += 1
		# refresh the key counter on the HUD
		hud.refresh_key_amount(number_of_keys)
		# display the item text
		if display_text:
			hud.display_text("Aquired a Key!", "Use it to open a locked door!")
	elif item == ItemType.type.shadow_heart:
		# if the player already has a shadow heart, add HP
		if shadow_heart == true:
			player_adjust_health(2)
		else:
			# add the shadow heart to the player
			shadow_heart = true
		# refresh the player's HP, and send that shadow_heart is active
		hud.refresh_hearts(player_health, shadow_heart)
		# display the item text
		if display_text:
			hud.display_text("Aquired the Shadow Heart!", "You follow the path of darkness now...")
		# add the item to the collected items in player data
		items_collected += [item]
		# mark that the shadow_heart has been collected (used for holy heart)
		if shadow_heart_collected == false:
			shadow_heart_collected = true
	elif item == ItemType.type.triple_blades:
		# add triple blades to the player
		triple_blades = true
		# display the item text
		if display_text:
			hud.display_text("Aquired Triple Blades!", "You can now throw 3 blades at once!")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.dust_blade:
		# add dust blades to the player
		dust_blade = true
		# set current blade to dust
		current_type = BladeType.blade_type.dust
		# display the item text
		if display_text:
			hud.display_text("Aquired Dust Blades!", "Attacks will slow enemies!")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.glass_blade:
		# add glass blades to the player
		glass_blade = true
		# set current blade to glass
		current_type = BladeType.blade_type.glass
		# display the item text
		if display_text:
			hud.display_text("Aquired Glass Blades!", "Blades will shoot shrapnel on hit!")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.holy_heart:
		# add the holy heart to the player
		# if the shadow_heart is active
		if shadow_heart == true:
			# remove the shadow_heart
			shadow_heart = false
			# removes the shadow_heart from the player's collected items
			remove_item_from_items_collected(ItemType.type.shadow_heart)
		else:
			# if the shadow_heart is not active, heal the player
			player_adjust_health(2)
		# refresh the player's HP, and send that shadow_heart is not active
		hud.refresh_hearts(player_health, shadow_heart)
		# display the item text
		if display_text:
			hud.display_text("Aquired the Holy Heart!", "You've been blessed!")
	elif item == ItemType.type.poorly_made_voodoo_doll:
		# add poorly made voodoo doll to the player
		poorly_made_voodoo_doll = true
		# display the item text
		if display_text:
			hud.display_text("Aquired a Poorly-made Voodoo Doll!", "Does this look like me?")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
		# do not allow the poorly made voodoo doll to be spawned
		can_poorly_made_voodoo_doll_be_spawned = false
	elif item == ItemType.type.sleek_blades:
		# add the sleek blade to the player
		knife_speed_bonus += ItemType.sleek_blade_speed_bonus
		# set current blade to sleek
		current_type = BladeType.blade_type.sleek
		# display the item text
		if display_text:
			hud.display_text("Aquired Sleek Blades!", "Blades move faster through the air.")
		# add the item to the collected items list on HUD and in player data
		add_passive_item(item)
	elif item == ItemType.type.dash_boots:
		# display the item text
		if display_text:
			hud.display_text("Aquired a Dash Boots!", "Allows you to dash by double tapping!")
		# add the usable item
		usable_item_added(item)
	elif item == ItemType.type.poison_gas:
		# display the item text
		if display_text:
			hud.display_text("Aquired a Bottle of Poison Gas!", "Breaking the bottle surrounds you poison!")
		# add the usable item
		usable_item_added(item)
	elif item == ItemType.type.protective_charm:
		# display the item text
		if display_text:
			hud.display_text("Aquired a Protective Charm!", "It's spawn will block some projectiles for you!")
		# adds the pet item and spawns in the pet to the player based on the item
		add_pet(item)
	elif item == ItemType.type.rogue_in_a_bottle:
		if display_text:
			hud.display_text("Aquired a Rogue-In-A-Bottle!", "Break when you need a little help!")
		# add the usable item
		usable_item_added(item)
	elif item == ItemType.type.hurtful_charm:
		# display the item text
		if display_text:
			hud.display_text("Aquired a Hurtful Charm!", "It will deal damage to enemies around you!")
		# adds the pet item and spawns in the pet to the player based on the item
		add_pet(item)
	elif item == ItemType.type.magically_trapped_rogue:
		# display the item text
		if display_text:
			hud.display_text("Aquired a Magically Trapped Rogue!", "He will throw knives at enemies so you won't drop him!")
		# adds the pet item and spawns in the pet to the player based on the item
		add_pet(item)
	elif item == ItemType.type.dead_rogues_head:
		# display the item text
		if display_text:
			hud.display_text("Aquired a Dead Rogue's Head", "His quest will end someday...")
		# adds the pet item and spawns in the pet to the player based on the item
		add_pet(item)
	elif item == ItemType.type.bomb:
		if display_text:
			hud.display_text("Aquired a Bomb!", "Use when you need an explosion!")
		# add the usable item
		usable_item_added(item)

# adds the item to the collected items list on HUD and in player data
func add_passive_item(item : ItemType.type):
	hud.item_added(item)
	items_collected += [item]

# removes the first item from items collected
func remove_item_from_items_collected(item_to_remove : ItemType.type, playsound : bool = true):
	if item_to_remove != ItemType.type.temp:
		for i in range(0, items_collected.size()):
			if items_collected[i] == item_to_remove:
				items_collected.remove_at(i)
				if playsound:
					item_break_sound.play()
				return

# use a key
func use_key():
	# if the player has keys
	if number_of_keys > 0:
		# use a key
		number_of_keys -= 1
		# refresh the key_amount on the HUD
		hud.refresh_key_amount(number_of_keys)
		# play the unlock door sound
		unlock_door_sound.play()
		# return that a key was used
		return true
	else:
		# return that a key was not used
		return false

## ------------------- usable item functions -------------------------------------------

# uses an item
func use_usable_item():
	# if an item can be used
	if can_use_item && current_usable_item != ItemType.type.temp:
		# does whatever the current item should do
		if current_usable_item == ItemType.type.dash_boots:
			# use an item
			used_usable_item()
			# dash
			dash()
		elif current_usable_item == ItemType.type.poison_gas:
			# use an item
			used_usable_item()
			# spawn the poison gas
			var poison_gas = PLAYER_FRIENDLY_POISON_AREA.instantiate()
			add_child(poison_gas)
			# set the usable item to temp (nothing)
			current_usable_item = ItemType.type.temp
			remove_item_from_items_collected(ItemType.type.poison_gas)
		elif current_usable_item == ItemType.type.rogue_in_a_bottle:
			# use an item
			used_usable_item()
			# spawn the poison gas
			var tiny_rogue = TINY_ROGUE.instantiate()
			get_parent().add_child(tiny_rogue)
			tiny_rogue.global_position = global_position
			## set the usable item to temp (nothing)
			current_usable_item = ItemType.type.temp
			remove_item_from_items_collected(ItemType.type.rogue_in_a_bottle)
		elif current_usable_item == ItemType.type.bomb:
			# use an item
			used_usable_item()
			# spawn the poison gas
			var bomb_instance = BOMB.instantiate()
			get_parent().add_child(bomb_instance)
			bomb_instance.global_position = global_position
			# remove 1 from the stack amount
			usable_item_stack_amount -= 1
			# if the stack is 0
			if usable_item_stack_amount == 0:
				# set the current usable itme to nothing
				current_usable_item = ItemType.type.temp
				# remove the move from items collected
				remove_item_from_items_collected(ItemType.type.bomb)
				# refresh the stack amount
				hud.adjust_usable_item_stack_amount(usable_item_stack_amount)
			# if the stack is  not 0
			else:
				# remove the move from items collected without sound
				remove_item_from_items_collected(ItemType.type.bomb, false)
				# refresh the stack amount
				hud.adjust_usable_item_stack_amount(usable_item_stack_amount)
		else:
			pass
		# if the current useable item is temp (nothing) remove the current_usable_item ui
		if current_usable_item == ItemType.type.temp:
			# hides the usable item UI
			hud.hide_usable_item()

# when a usable item is added
func usable_item_added(item : ItemType.type):
	var stackable = false
	for item_type in ItemType.stackable_items:
		if item == item_type:
			stackable = true
	if !stackable:
		# removes the current_usable_item from the player's collected items
		remove_item_from_items_collected(current_usable_item)
		# set the current item for the player to the dash boots
		current_usable_item = item
		# reset the item stack
		usable_item_stack_amount = 1
		hud.adjust_usable_item_stack_amount(usable_item_stack_amount)
	# if the item is stackable
	elif stackable:
		if current_usable_item == item:
			usable_item_stack_amount += 1
		else:
			# removes the current_usable_item from the player's collected items
			remove_item_from_items_collected(current_usable_item)
			# set the current item for the player to the dash boots
			current_usable_item = item
			# set the usable item stack to 1
			usable_item_stack_amount = 1
		# adjust the usable items stack UI
		hud.adjust_usable_item_stack_amount(usable_item_stack_amount)
	hud.current_usable_item(current_usable_item)
	if item != ItemType.type.temp:
		items_collected += [item]

# when an item is used
func used_usable_item():
	# disable the use of items
	can_use_item = false
	# start the use item cooldown timer for the item cooldown
	usable_item_cooldown_timer.start(use_item_cooldown)
	# show the hud's cooldown
	hud.used_usable_item(use_item_cooldown)

# when the use item cooldown timer ends
func _on_usable_item_cooldown_timer_timeout():
	# set that usable items can be used
	can_use_item = true
	# if the current_usable item is temp (nothing)
	if current_usable_item == ItemType.type.temp:
		# hides the usable item UI
		hud.hide_usable_item()

# when the voodoo doll immunity timer ends
func _on_voodoo_doll_immunity_timer_timeout():
	# set immunity to false
	immunity = false
	# remove the poorly made voodoo doll from the items collected
	remove_item_from_items_collected(ItemType.type.poorly_made_voodoo_doll)
	# remove the poorly made voodoo doll from the items collected ui
	hud.remove_item_from_ui(ItemType.type.poorly_made_voodoo_doll)

# when the player dashes
func dash():
	# start the dash timer
	dash_timer.start()
	# set that the player is dashing
	is_dashing = true
	# start the after image spawn timer
	after_image_spawn_timer.start()

# when the dash timer ends
func _on_dash_timer_timeout():
	is_dashing = false

# when the after image spawn timer ends
func _on_after_image_spawn_timer_timeout():
	# spawn an after image
	var after_image = PLAYER_AFTER_IMAGE.instantiate()
	get_parent().add_child(after_image)
	after_image.global_position = global_position
	# increment after images
	after_images += 1
	# if there aren't 2 after images down
	if after_images < 3:
		# start the after image spawn timer
		after_image_spawn_timer.start()
	# if there two after images down
	else:
		# reset the after images
		after_images = 0


## ------------------- pet functions -------------------------------------------

# adds a pet based on the item type
func add_pet(pet_item : ItemType.type):
	if pet_item != ItemType.type.temp:
		# add the item to the collected items list on HUD and in player data
		add_passive_item(pet_item)
		# if there is a current pet
		if current_pet != null:
			# remove the pet and the pet's item
			current_pet.kill_pet()
			remove_item_from_items_collected(current_pet_item)
			hud.remove_item_from_ui(current_pet_item)
		# set the pet to be spawned based on it's item type
		var spawn = null
		if pet_item == ItemType.type.protective_charm:
			spawn = PROTECTIVE_CHARM_SPAWN.instantiate()
		elif pet_item == ItemType.type.hurtful_charm:
			spawn = HURTFUL_CHARM_SPAWN.instantiate()
		elif pet_item == ItemType.type.magically_trapped_rogue:
			spawn = DANGLING_ROGUE.instantiate()
		elif pet_item == ItemType.type.dead_rogues_head:
			spawn = DEAD_ROGUE.instantiate()
		# if there is a pet to be spawned
		if spawn !=  null:
			# spawn that pet
			current_pet_item = pet_item
			add_child(spawn)
			current_pet = spawn

# when a pet dies
func pet_died(pet_item : ItemType.type):
	# remove the pet_item from the items collected and UI
	remove_item_from_items_collected(pet_item)
	hud.remove_item_from_ui(pet_item)
	# remove the current pet
	current_pet = null


## ------------------- other functions needed -------------------------------------------

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the player enters a room
func room_entered():
	# reset the attack identifier
	current_attack_identifier = 0
	# reset attack that have hit (used mainly for the morphed shade fight)
	attacks_that_have_hit = []
