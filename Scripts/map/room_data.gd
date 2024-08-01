extends Node

# types of rooms
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

# current room
var current_room = null

## scenes used in rooms
# put things on floor as a child of this
const FLOOR_TEXT = preload("res://Scenes/map/room_components/floor_text.tscn")
# tutorial for floor 1 spawn
const TUTORIAL = preload("res://Scenes/map/room_components/tutorial.tscn")
# item spawners
const ITEM_CHEST = preload("res://Scenes/item_chest.tscn")
const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")
# teleporters between floors
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

# floor 1 mobs
const SLIME = preload("res://Scenes/enemies/slime.tscn")
var floor_1_mobs = [
	SLIME,
]

# floor 2 mobs
const AIR_ELEMENTAL = preload("res://Scenes/enemies/air_elemental.tscn")
const EARTH_ELEMENTAL = preload("res://Scenes/enemies/earth_elemental.tscn")
var floor_2_mobs = [
	AIR_ELEMENTAL,
	EARTH_ELEMENTAL,
]

# floor 3 mobs
const SKELETON_ARCHER = preload("res://Scenes/enemies/skeleton_archer.tscn")
const SKELETON_MAGE = preload("res://Scenes/enemies/skeleton_mage.tscn")
const SKELETON_WARRIOR = preload("res://Scenes/enemies/skeleton_warrior.tscn")
var floor_3_mobs = [
	SKELETON_ARCHER,
	SKELETON_MAGE,
	SKELETON_WARRIOR,
]

# floor 4 mobs
const SHADE = preload("res://Scenes/enemies/shade.tscn")
const TINY_DEVIL = preload("res://Scenes/enemies/tiny_devil.tscn")
var floor_4_mobs = [
	SHADE,
	TINY_DEVIL,
]
