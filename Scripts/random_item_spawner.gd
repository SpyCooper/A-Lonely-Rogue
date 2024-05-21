extends Node2D

const DUST_BLADE_ITEM = preload("res://Scenes/items/dust_blade_item.tscn")
const GLASS_BLADE_ITEM = preload("res://Scenes/items/glass_blade_item.tscn")
const POISONED_BLADES_ITEM = preload("res://Scenes/items/poisoned_blades_item.tscn")
const QUICK_BLADES_ITEM = preload("res://Scenes/items/quick_blades_item.tscn")
const SHADOW_BLADE_ITEM = preload("res://Scenes/items/shadow_blade_item.tscn")
const SHADOW_FLAME_ITEM = preload("res://Scenes/items/shadow_flame_item.tscn")
const TRIPLE_BLADES_ITEM = preload("res://Scenes/items/triple_blades_item.tscn")

const SHADOW_HEART_ITEM = preload("res://Scenes/items/shadow_heart_item.tscn")
const SPEED_BOOTS_ITEM = preload("res://Scenes/items/speed_boots_item.tscn")
const KEY_ITEM = preload("res://Scenes/items/key_item.tscn")

const HEART_1_PICKUP = preload("res://Scenes/items/heart_1_pickup.tscn")
const HEART_2_PICKUP = preload("res://Scenes/items/heart_2_pickup.tscn")

var rng = RandomNumberGenerator.new()

var item_array = [
	DUST_BLADE_ITEM,
	GLASS_BLADE_ITEM,
	POISONED_BLADES_ITEM,
	QUICK_BLADES_ITEM,
	SHADOW_BLADE_ITEM,
	SHADOW_FLAME_ITEM,
	TRIPLE_BLADES_ITEM,
	SHADOW_HEART_ITEM,
	SPEED_BOOTS_ITEM,
	KEY_ITEM,
	HEART_1_PICKUP,
	HEART_2_PICKUP,
	]
var item_types_array = [
	ItemType.type.dust_blade,
	ItemType.type.glass_blade,
	ItemType.type.poisoned_blades,
	ItemType.type.quick_blades,
	ItemType.type.shadow_blade,
	ItemType.type.shadow_flame,
	ItemType.type.triple_blades,
	ItemType.type.shadow_heart,
	ItemType.type.speed_boots,
	ItemType.type.key,
	ItemType.type.health_1,
	ItemType.type.health_2,
	]

func _ready():
	Events.room_entered.connect(func(room):
		if room == get_parent():
			spawn_item()
	)

func spawn_item():
	var random_item_key = rng.randi_range(0, item_array.size()-1)
	var item_has_spawned = false
	for item in ItemType.get_spawned_items():
		if item == item_types_array[random_item_key]:
			if (item_types_array[random_item_key] != ItemType.type.health_2 && 
			item_types_array[random_item_key] != ItemType.type.health_1 && 
			item_types_array[random_item_key] != ItemType.type.key):
				item_has_spawned = true
	if item_has_spawned == false:
		var spawned_item = item_array[random_item_key].instantiate()
		spawned_item.position = position
		get_parent().add_child(spawned_item)
		ItemType.add_spawned_item(item_types_array[random_item_key])
		queue_free()
	else:
		spawn_item()
	
