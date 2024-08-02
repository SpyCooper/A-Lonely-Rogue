extends Node2D

# other items
const HEART_1_PICKUP = preload("res://Scenes/items/heart_1_pickup.tscn")
const HEART_2_PICKUP = preload("res://Scenes/items/heart_2_pickup.tscn")

# random number generator
var rng = RandomNumberGenerator.new()

# on start
func _ready():
	# when the room_entered signal is set
	Events.room_entered.connect(func(room):
		# if the player is in the room, spawn an item
		if room == get_parent():
			spawn_item()
	)

# spawns a random item
func spawn_item():
	# get a random item from the item_array
	var random_health = rng.randi_range(0, 1)
	
	var spawned_item
	if random_health == 0:
		spawned_item = HEART_1_PICKUP.instantiate()
	elif random_health == 1:
		spawned_item = HEART_2_PICKUP.instantiate()
	get_tree().current_scene.add_child(spawned_item)
	spawned_item.global_position = global_position
	# remove the item spawner
	queue_free()
	

	
