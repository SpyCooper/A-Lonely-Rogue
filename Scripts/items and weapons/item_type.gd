extends Node

# sets the various item types
enum type
{
	temp,
	health_2,
	health_1,
	poisoned_blades,
	speed_boots,
	quick_blades,
	shadow_flame,
	shadow_blade,
	glass_blade,
	dust_blade,
	triple_blades,
	key,
	shadow_heart,
}

# sets the spawned items in the floor
var spawned_items = []

var speed_boots_movement_speed_bonus = 10

# return spawned items
func get_spawned_items():
	return spawned_items

# adds a spawned item to the spawned_items list
func add_spawned_item(item_added : type):
	spawned_items += [item_added]
