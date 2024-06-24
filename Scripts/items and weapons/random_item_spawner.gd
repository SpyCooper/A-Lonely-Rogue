extends Node2D

# weapons items
const DUST_BLADE_ITEM = preload("res://Scenes/items/dust_blade_item.tscn")
const GLASS_BLADE_ITEM = preload("res://Scenes/items/glass_blade_item.tscn")
const POISONED_BLADES_ITEM = preload("res://Scenes/items/poisoned_blades_item.tscn")
const QUICK_BLADES_ITEM = preload("res://Scenes/items/quick_blades_item.tscn")
const SHADOW_BLADE_ITEM = preload("res://Scenes/items/shadow_blade_item.tscn")
const SHADOW_FLAME_ITEM = preload("res://Scenes/items/shadow_flame_item.tscn")
const TRIPLE_BLADES_ITEM = preload("res://Scenes/items/triple_blades_item.tscn")

# other items
const SHADOW_HEART_ITEM = preload("res://Scenes/items/shadow_heart_item.tscn")
const SPEED_BOOTS_ITEM = preload("res://Scenes/items/speed_boots_item.tscn")
const KEY_ITEM = preload("res://Scenes/items/key_item.tscn")
const HEART_1_PICKUP = preload("res://Scenes/items/heart_1_pickup.tscn")
const HEART_2_PICKUP = preload("res://Scenes/items/heart_2_pickup.tscn")
const HOLY_HEART_ITEM = preload("res://Scenes/items/holy_heart_item.tscn")
const POORLY_MADE_VOODOO_DOLL_ITEM = preload("res://Scenes/items/poorly_made_voodoo_doll_item.tscn")

# random number generator
var rng = RandomNumberGenerator.new()

# variable of items objects
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
	HOLY_HEART_ITEM,
	POORLY_MADE_VOODOO_DOLL_ITEM,
	]
# variable of item types in the same position of the item objects
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
	ItemType.type.holy_heart,
	ItemType.type.poorly_made_voodoo_doll,
	]

# on start
func _ready():
	# when the room_entered signal is set
	Events.room_entered.connect(func(room):
		# if the player is in the room, spawn an item
		if room == get_parent():
			spawn_item()
	)

# spawns a random item
func spawn_item():
	# get a random item from the item_array
	var random_item_key = rng.randi_range(0, item_array.size()-1)
	var item_has_spawned = false
	var item_can_spawn = true
	# for each item in items that have been spawned
	for item in ItemType.get_spawned_items():
		# if the item that has been spawned matches the random item
		if item == item_types_array[random_item_key]:
			# if the item is not a key or health item
			if (item_types_array[random_item_key] != ItemType.type.health_2 && 
			item_types_array[random_item_key] != ItemType.type.health_1 && 
			item_types_array[random_item_key] != ItemType.type.key && 
			item_types_array[random_item_key] != ItemType.type.speed_boots && 
			item_types_array[random_item_key] != ItemType.type.quick_blades && 
			item_types_array[random_item_key] != ItemType.type.sleek_blades):
				# mark that the item has already been spawned
				item_has_spawned = true
		
		## checks if the item can be spawned
		
		# checks if the item type is a holy heart
		if item_types_array[random_item_key] == ItemType.type.holy_heart:
			# checks to see if the player has the shadow_heart
			if Events.player.shadow_heart != true:
				# if the player doesn't have a shadow_heart and the type was holy_heart, the item cannot spawn
				item_can_spawn = false
	
	# if the item is not spawned and can spawned
	if item_has_spawned == false && item_can_spawn == true:
		# spawn the item
		var spawned_item = item_array[random_item_key].instantiate()
		spawned_item.position = position
		get_parent().add_child(spawned_item)
		ItemType.add_spawned_item(item_types_array[random_item_key])
		# remove the item spawner
		queue_free()
	# if the item has already been spawned, call spawn item again
	elif item_has_spawned == true:
		spawn_item()
	
