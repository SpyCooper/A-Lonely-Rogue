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

const FLOOR_TEXT = preload("res://Scenes/map/room_components/floor_text.tscn")

# tutorial room text
const TUTORIAL = preload("res://Scenes/map/room_components/tutorial.tscn")

const ITEM_CHEST = preload("res://Scenes/item_chest.tscn")

const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")

const TRAPDOOR = preload("res://Scenes/Dungeon_floors/trapdoor.tscn")

# main floor bosses
const GELATINOUS_CUBE = preload("res://Scenes/enemies/gelatinous_cube.tscn")
const FORGOTTEN_GOLEM = preload("res://Scenes/enemies/forgotten_golem.tscn")
const LICH = preload("res://Scenes/enemies/lich.tscn")
const LOST_KNIGHT = preload("res://Scenes/enemies/lost_knight.tscn")

# crystal bosses
const SAPPHIRE_PEGASUS = preload("res://Scenes/enemies/sapphire_pegasus.tscn")
const QUARTZ_BEHEMOTH = preload("res://Scenes/enemies/quartz_behemoth.tscn")
const EMERALD_SKELETON = preload("res://Scenes/enemies/emerald_skeleton.tscn")
const ONYX_DEMON = preload("res://Scenes/enemies/onyx_demon.tscn")
