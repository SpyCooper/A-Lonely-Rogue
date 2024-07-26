extends Node

enum room_types
{
	starting,
	no_type,
	chest,
	random_item,
	locked_item,
	monster,
	crystal_boss,
	boss,
	ending,
}

var floor_1_mobs = []

var current_room = null
