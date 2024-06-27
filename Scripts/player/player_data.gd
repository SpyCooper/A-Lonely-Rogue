extends Node

# sets data to be transferred between floor

# variables
var player_health = 6
var number_of_keys = 0
var items_collected = []
var current_pet_health = 0

var health_healed = 0
var damage_taken = 0
var items_used = []

# clears the data saved for the player
func clear_data():
	items_collected = []
	number_of_keys = 0
	player_health = 6
	current_pet_health = 0

# clears the data for this dungeon run
func clear_run_data():
	items_collected = []
	number_of_keys = 0
	player_health = 6
	current_pet_health = 0
	
	health_healed = 0
	damage_taken = 0
	items_used = []
