extends Node2D

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


var has_sapphire = false
var has_quartz = false
var has_emerald = false
var has_onyx = false
var can_combine = false
var player = null
var items_destroyed = 0
var move_player_to_circle = false

func _ready():
	Events.room_entered.connect(func(room):
		if room == get_parent():
			check_items()
	)
	
	horn_item.hide()
	boots_item.hide()
	skull_item.hide()
	hand_item.hide()

func _physics_process(delta):
	if move_player_to_circle && player != null:
		if magic_circle_sprite.global_position.distance_to(player.get_player_position()) > 1:
			player.velocity = (magic_circle_sprite.global_position - player.get_player_position()).normalized() * (player.get_speed()/2)
			player.move_and_slide()
		else:
			player.set_player_position(magic_circle_sprite.global_position)
			item_destruction_timer.start()
			move_player_to_circle = false

func check_items():
	print(Events.player.items_collected)
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
	
	if has_emerald && has_onyx && has_quartz && has_sapphire:
		magic_circle_sprite.play("enabled")
		can_combine = true


func _on_magic_circle_area_body_entered(body):
	if body is Player:
		player = body
		if can_combine && player != null:
			player.player_can_move = false
			move_player_to_circle = true


func _on_item_destruction_timer_timeout():
	if items_destroyed == 0:
		player.remove_item_from_inventory(ItemType.type.sapphire_horn)
		horn_item.show()
		items_destroyed += 1
		item_destruction_timer.start()
	elif items_destroyed == 1:
		player.remove_item_from_inventory(ItemType.type.quartz_boots)
		boots_item.show()
		items_destroyed += 1
		item_destruction_timer.start()
	elif items_destroyed == 2:
		player.remove_item_from_inventory(ItemType.type.emerald_skull)
		skull_item.show()
		items_destroyed += 1
		item_destruction_timer.start()
	elif items_destroyed == 3:
		player.remove_pet_from_inventory(ItemType.type.onyx_hand)
		hand_item.show()
		items_destroyed += 1
		item_destruction_timer.start()
	elif items_destroyed == 4:
		horn_item.play("light")
		boots_item.play("light")
		skull_item.play("light")
		hand_item.play("light")
		spawn_circle_sprite.play("glow")
		magic_circle_sprite.play("final_glow")
		glow_timer.start()

func _on_glow_timer_timeout():
	create_crystal_beast_item()

func create_crystal_beast_item():
	player_move_offset_timer.start()


func _on_player_move_offset_timer_timeout():
	player.player_can_move = true
	horn_item.hide()
	boots_item.hide()
	skull_item.hide()
	hand_item.hide()
	
	sapphire_horn_sprite.play("unobtained")
	quartz_boots_sprite.play("unobtained")
	emerald_skull_sprite.play("unobtained")
	onyx_hand_sprite.play("unobtained")
	
	has_sapphire = false
	has_emerald = false
	has_onyx = false
	has_quartz = false
	can_combine = false
	
	#magic_circle_sprite.play("disabled")
	#spawn_circle_sprite.play("default")
