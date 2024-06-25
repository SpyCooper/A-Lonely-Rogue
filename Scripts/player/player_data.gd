extends Node

# sets data to be transferred between floor

# variables
var player_health = 6
var number_of_keys = 0
var items_collected = []
var current_pet_health = 0

# clears the data saved for the player
func clear_data():
	items_collected = []
	number_of_keys = 0
	player_health = 6
	current_pet_health = 0
