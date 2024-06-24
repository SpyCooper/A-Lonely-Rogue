extends Node

# sets data to be transferred between floor

# variables
var player_health = 6
var number_of_keys = 0
var items_collected = []

func clear_data():
	items_collected = []
	number_of_keys = 0
	player_health = 6
