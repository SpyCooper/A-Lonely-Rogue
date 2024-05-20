extends Node

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

var spawned_items = []

func get_spawned_items():
	return spawned_items

func add_spawned_item(item_added : type):
	spawned_items += [item_added]
