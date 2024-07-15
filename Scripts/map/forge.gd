extends Node2D

# object references
@onready var magic_circle_sprite = $magic_circle_sprite
@onready var sapphire_horn_sprite = $sapphire_horn_sprite
@onready var quartz_boots_sprite = $quartz_boots_sprite
@onready var emerald_skull_sprite = $emerald_skull_sprite
@onready var onyx_hand_sprite = $onyx_hand_sprite
@onready var item_destruction_timer = $item_destruction_timer
@onready var horn_item = $horn_item
@onready var boots_item = $boots_item
@onready var skull_item = $skull_item
@onready var hand_item = $hand_item
@onready var glow_timer = $glow_timer
@onready var spawn_circle_sprite = $spawn_circle_sprite
@onready var player_move_offset_timer = $player_move_offset_timer
@onready var object_1 = $object_1
@onready var object_2 = $object_2
@onready var object_3 = $object_3
@onready var object_4 = $object_4
@onready var glowing_sound = $glowing_sound
@onready var forge_active_sound = $forge_active_sound
const CHROMATIC_ORB_ITEM = preload("res://Scenes/items/chromatic_orb_item.tscn")

# variables
var has_sapphire = false
var has_quartz = false
var has_emerald = false
var has_onyx = false
var can_combine = false
var player = null
var items_destroyed = 0
var move_player_to_circle = false

# on ready
func _ready():
	# when the player enters the room
	Events.room_entered.connect(func(room):
		# if the room is the current room
		if room == get_parent():
			# check the items
			check_items()
	)
	# hide the item sprites on the pillars
	horn_item.hide()
	boots_item.hide()
	skull_item.hide()
	hand_item.hide()

# on a set intercal
func _physics_process(_delta):
	# if move player to the circle is true and the player is not null
	if move_player_to_circle && player != null:
		# if the player is further than 1 pixel
		if magic_circle_sprite.global_position.distance_to(player.get_player_position()) > 1:
			# move the player towards the magic circle
			player.velocity = (magic_circle_sprite.global_position - player.get_player_position()).normalized() * (player.get_speed()/2)
			player.move_and_slide()
		# if he player is 1 pixel or closer
		else:
			# set the player's position on the magic circle
			player.set_player_position(magic_circle_sprite.global_position)
			# start the item destructions
			item_destruction_timer.start()
			# stop moving the player towards the circle
			move_player_to_circle = false

# checks the items the player has for the 4 crystal items
func check_items():
	for item in Events.player.items_collected:
		if item == ItemType.type.sapphire_horn:
			has_sapphire = true
			sapphire_horn_sprite.play("obtained")
		elif item == ItemType.type.quartz_boots:
			has_quartz = true
			quartz_boots_sprite.play("obtained")
		elif item == ItemType.type.emerald_skull:
			has_emerald = true
			emerald_skull_sprite.play("obtained")
		elif item == ItemType.type.onyx_hand:
			has_onyx = true
			onyx_hand_sprite.play("obtained")
	# if all the crystal items are in the player's inventory
	if has_emerald && has_onyx && has_quartz && has_sapphire:
		# enable the magic circle
		magic_circle_sprite.play("enabled")
		can_combine = true
		# play the forge active sound
		forge_active_sound.play()

# when the player enters the magic circle
func _on_magic_circle_area_body_entered(body):
	if body is Player:
		player = body
		# if the player can combine the crystal items, start moving the player to the circle
		if can_combine && player != null:
			player.player_can_move = false
			move_player_to_circle = true

# when the item destruction timer ends
func _on_item_destruction_timer_timeout():
	# if item 1 is to be removed
	if items_destroyed == 0:
		# remove the horn
		player.remove_item_from_inventory(ItemType.type.sapphire_horn)
		horn_item.show()
		items_destroyed += 1
		# start the item destruction timer
		item_destruction_timer.start()
		# play the item_1 destruction sound
		object_1.play()
	# if item 2 is to be removed
	elif items_destroyed == 1:
		# remove the boots
		player.remove_item_from_inventory(ItemType.type.quartz_boots)
		boots_item.show()
		items_destroyed += 1
		# start the item destruction timer
		item_destruction_timer.start()
		# play the item_2 destruction sound
		object_2.play()
	# if item 3 is to be removed
	elif items_destroyed == 2:
		# remove the skull
		player.remove_item_from_inventory(ItemType.type.emerald_skull)
		skull_item.show()
		items_destroyed += 1
		# start the item destruction timer
		item_destruction_timer.start()
		# play the item_3 destruction sound
		object_3.play()
	# if item 4 is to be removed
	elif items_destroyed == 3:
		# remove the hand
		player.remove_pet_from_inventory(ItemType.type.onyx_hand)
		hand_item.show()
		items_destroyed += 1
		# start the item destruction timer
		item_destruction_timer.start()
		# play the item_4 destruction sound
		object_4.play()
	# if all 4 items have been removed
	elif items_destroyed == 4:
		# make all the circles and items glow
		horn_item.play("light")
		boots_item.play("light")
		skull_item.play("light")
		hand_item.play("light")
		spawn_circle_sprite.play("glow")
		magic_circle_sprite.play("final_glow")
		# start the glow timer
		glow_timer.start()
		# play the glowing sound
		glowing_sound.play()

# when the glow timer ends
func _on_glow_timer_timeout():
	# create the chromatic orb
	create_chromatic_orb_item()
	# starts the player move_offset_timer
	player_move_offset_timer.start()

# spawns the chromatic orb item on the small magic circle
func create_chromatic_orb_item():
	var orb = CHROMATIC_ORB_ITEM.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = spawn_circle_sprite.global_position
	orb.spawned()

# when the player move_offset_timer ends
func _on_player_move_offset_timer_timeout():
	# allow the player to move
	player.player_can_move = true
	# hide the item s on the pillars
	horn_item.hide()
	boots_item.hide()
	skull_item.hide()
	hand_item.hide()
	# switch the pillar sprites to unobtained
	sapphire_horn_sprite.play("unobtained")
	quartz_boots_sprite.play("unobtained")
	emerald_skull_sprite.play("unobtained")
	onyx_hand_sprite.play("unobtained")
	# set the items collect bools to false
	has_sapphire = false
	has_emerald = false
	has_onyx = false
	has_quartz = false
	can_combine = false
