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

# references related to the falling animation at the start of each floor
@onready var fall_timer = $fall_timer
@onready var falling_shadow_sprite = $falling_shadow_sprite
@onready var stand_up_sprite = $stand_up_sprite
@onready var stand_up_timer = $stand_up_timer
@onready var falling_sprite = $falling_sprite
@onready var falling_animation_player = $falling_sprite/falling_AnimationPlayer
@onready var player_fall_sound = $player_fall_sound
@onready var player_fall_sound_timer = $player_fall_sound/player_fall_sound_timer

# constants
const KNIFE_SPEED = 150.0
const PLAYER_HEALTH_MAX = 10

# variables
var lastMove = "default"
var attacks_per_second = 1
var attack_damage = 1
var time_to_fire = 0.0
var time_to_fire_max = 1.0
var player_health = 6
var speed = 100.0
var number_of_keys = 0
var dying = false
var player_can_move = false

# upgrade variables
var poisoned_blade = false
var shadow_blade = false
var glass_blade = false
var shadow_flame_blade = false
var dust_blade = false
var triple_blades = false
var shadow_heart = false
var current_type : BladeType.blade_type = BladeType.blade_type.default
var knife_scene = load("res://Scenes/knife.tscn")
var items_collected = []

# runs on start
func _ready():
	# sets the stats for the player
	attacks_per_second = 1
	time_to_fire_max = time_to_fire_max / attacks_per_second
	Events.player = self
	# plays the fall animation
	player_can_move = false
	animated_sprite.hide()
	falling_shadow_sprite.show()
	falling_shadow_sprite.play("default")
	falling_animation_player.play("player_falling")
	stand_up_sprite.hide()
	# if the current floor is 1, hide hud during fall
	if get_tree().current_scene.name == "Floor1":
		hud.hide()
	hud.refresh_key_amount(number_of_keys)
	fall_timer.start()
	player_fall_sound_timer.start()
	
	# load the player data, if there is any
	# used to transfer data between floor
	load_player_data()

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
		velocity = direction * speed
		
		# controls the animations for the movement
		if direction.y == -1:
			animated_sprite.play("move_up")
			lastMove = "move_up"
		elif direction.y == 1:
			animated_sprite.play("move_down")
			lastMove = "move_down"
		elif direction.x < 0:
			animated_sprite.play("move_left")
			lastMove = "move_left"
		elif direction.x > 0:
			animated_sprite.play("move_right")
			lastMove = "move_right"
		else:
			# sets the idle animations based on the last movemnet
			if lastMove == "move_right":
				animated_sprite.play("idle_right")
			elif lastMove == "move_left":
				animated_sprite.play("idle_left")
			elif lastMove == "move_up":
				animated_sprite.play("idle_up")
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
				blade_instance.spawned(click_position_normalized, current_type, self)
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
					blade_instance_2.spawned(rad_added_bottom, current_type, self)
					get_parent().add_child(blade_instance_2)
					# top blade
					var rad_added_top = Vector2(cos(radians - 0.25), sin(radians - 0.25))
					rad_added_top = rad_added_top.normalized()
					var blade_instance_3 = knife_scene.instantiate()
					blade_instance_3.position = position + rad_added_top*3
					blade_instance_3.spawned(rad_added_top, current_type, self)
					get_parent().add_child(blade_instance_3)
				
				# resets the time to fire
				time_to_fire = time_to_fire_max

# runs when an enemy hits the player
func player_take_damage():
	player_adjust_health(-1)
	hit_sound.play()
	hit_flash_animation_player.play("hit_flash")

# when the death_timer runs out, the scene resets
func _on_timer_timeout():
	get_tree().reload_current_scene()
	Engine.time_scale = 1

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
		print("picked up temp item")
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
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.speed_boots:
		# increase the player's speed
		speed += 15
		# display the item text
		if display_text:
			hud.display_text("Aquired Speed Boots!", "You run faster.")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.quick_blades:
		# increase attack speed
		attacks_per_second += 1
		#recalculate the attack_speed()
		calculate_attack_speed()
		# display the item text
		if display_text:
			hud.display_text("Aquired Quicker Blades!", "Blades can be thrown faster.")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.shadow_flame:
		# add the shadow flame blade to the player
		shadow_flame_blade = true
		# set current blade to shadow flame
		current_type = BladeType.blade_type.shadow_flame
		# display the item text
		if display_text:
			hud.display_text("Aquired Shadowflame!", "Blades damage enemies after a time for moderate damage.")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.shadow_blade:
		# add the shadow blade to the player
		shadow_blade = true
		# set current blade to shadow
		current_type = BladeType.blade_type.shadow
		# display the item text
		if display_text:
			hud.display_text("Aquired Shadow Blades!", "Blades do increased damage.")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.key:
		# increase the number of keys
		number_of_keys += 1
		# refresh the key counter on the HUD
		hud.refresh_key_amount(number_of_keys)
		# display the item text
		if display_text:
			hud.display_text("Aquired a Key!", "Use it to open a locked door!")
	elif item == ItemType.type.shadow_heart:
		# add the shadow heart to the player
		shadow_heart = true
		# refresh the player's HP, and send that shadow_heart is active
		hud.refresh_hearts(player_health, shadow_heart)
		# display the item text
		if display_text:
			hud.display_text("Aquired the Shadow Heart!", "You follow the path of darkness now...")
		# add the item to the collected items in player data
		items_collected += [item]
	elif item == ItemType.type.triple_blades:
		# add triple blades to the player
		triple_blades = true
		# display the item text
		if display_text:
			hud.display_text("Aquired Triple Blades!", "You can now throw 3 blades at once!")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.dust_blade:
		# add dust blades to the player
		dust_blade = true
		# set current blade to dust
		current_type = BladeType.blade_type.dust
		# display the item text
		if display_text:
			hud.display_text("Aquired Dust Blades!", "Attacks will slow enemies!")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]
	elif item == ItemType.type.glass_blade:
		# add glass blades to the player
		glass_blade = true
		# set current blade to glass
		current_type = BladeType.blade_type.glass
		# display the item text
		if display_text:
			hud.display_text("Aquired Glass Blades!", "Blades will shoot shrapnel on hit!")
		# add the item to the collected items list on HUD and in player data
		hud.item_added(item)
		items_collected += [item]

# calculate the attack speed
func calculate_attack_speed():
	time_to_fire_max = time_to_fire_max / attacks_per_second

# adjust player's health
# used to heal and take damage
func player_adjust_health(change : int):
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
		# set the time scale to .5
		Engine.time_scale = 0.5
		# set state to dying
		dying = true
		# start death timer
		death_timer.start()
		# play the death animation
		animated_sprite.play("death")

# returns the current weapons
func get_current_weapons():
	var current_blades = []
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
		player_adjust_health(1)

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

# return if the player is dying
func get_is_dying():
	return dying

# when the fall timer ends
func _on_fall_timer_timeout():
	# hide the fall and fall shadow sprites
	falling_shadow_sprite.hide()
	falling_sprite.hide()
	# play the stand up animation
	stand_up_sprite.show()
	stand_up_sprite.play("stand_up")
	# start the stand up timer
	stand_up_timer.start()

# when the stand up timer ends
func _on_stand_up_timer_timeout():
	# show the normal animated sprite
	animated_sprite.show()
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

# save the player data to transfer between floors
func save_player_data():
	PlayerData.player_health = player_health
	PlayerData.number_of_keys = number_of_keys
	PlayerData.items_collected = items_collected

# load the player data from previous floors
func load_player_data():
	player_health = PlayerData.player_health
	number_of_keys = PlayerData.number_of_keys
	# recollect the items obtained
	items_collected = PlayerData.items_collected
	for item in items_collected:
		picked_up_item(item, false, false)
	# refresh the HUD
	hud.refresh_hearts(player_health)
	hud.refresh_key_amount(number_of_keys)

# when the player fall sound timer ends, play the fall sound
func _on_player_fall_sound_timer_timeout():
	player_fall_sound.play()
