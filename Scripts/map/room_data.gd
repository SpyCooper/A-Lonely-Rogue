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

# tutorial room text
const TUTORIAL = preload("res://Scenes/map/room_components/tutorial.tscn")

const ITEM_CHEST = preload("res://Scenes/item_chest.tscn")
const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")
