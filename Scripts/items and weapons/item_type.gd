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
	holy_heart,
	poorly_made_voodoo_doll,
	cursed_key,
	lady_lucks_key,
	dash_boots,
	sleek_blades,
	poison_gas,
	protective_charm,
	rogue_in_a_bottle,
	hurtful_charm,
	magically_trapped_rogue,
	dead_rogues_head,
	bomb,
	emerald_skull,
	sapphire_horn,
	quartz_boots,
	onyx_hand,
	chromatic_orb,
}

# sets the various item types
var repeatable_items = [
	type.health_2,
	type.health_1,
	type.speed_boots,
	type.quick_blades,
	type.key,
	type.sleek_blades,
	type.shadow_heart,
	type.holy_heart,
	type.bomb,
]

# sets the various item types
var stackable_items = [
	type.bomb,
]

# sets the spawned items in the floor
var spawned_items = []

# sets the upgrade values used between the player and morphed shade
var speed_boots_movement_speed_bonus = 10
var quick_blades_attack_speed_bonus = 0.25
var sleek_blade_speed_bonus = 25
var sapphire_horn_speed_boost = 10

# return spawned items
func get_spawned_items():
	return spawned_items

# adds a spawned item to the spawned_items list
func add_spawned_item(item_added : type):
	spawned_items += [item_added]
