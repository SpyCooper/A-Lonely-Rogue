extends Area2D

# object references
const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var open_sound = $open_sound
const MIMIC = preload("res://Scenes/enemies/mimic.tscn")

# defines is mimic variables
var rng = RandomNumberGenerator.new()
var is_mimic = true

# variables
var item

func _ready():
	var random_number = rng.randi_range(0, 5)
	if random_number > 4:
		is_mimic = true

# when a player enters the area
func _on_body_entered(body):
	if body is Player:
		if is_mimic:
			spawn_mimic()
		else:
			spawn_item()

# when a knife enters the area
func _on_area_entered(area):
	if area is Knife:
		if is_mimic:
			spawn_mimic()
		else:
			spawn_item()

# when the timer ends, spawn an item and remove the chest
func _on_timer_timeout():
	item.spawn_item()
	queue_free()

func spawn_item():
	# create a random item spawner
	var random_item = RANDOM_ITEM_SPAWNER.instantiate()
	random_item.position = position
	item = random_item
	get_parent().add_child(random_item)
	# play the animation
	animated_sprite.play("default")
	# start the timer
	timer.start(4.0/10.0)
	# play the opening sound
	open_sound.play()

# spawn a mimic
func spawn_mimic():
	# spawn in a mimic
	var mimic = MIMIC.instantiate()
	add_child(mimic)
	mimic.reparent(get_parent())
	mimic.global_position = global_position
	mimic.spawned_in_room()
	# let the room know a mimic has spawned
	Events.current_room.enemy_spawned(mimic)
	# remove the chest
	queue_free()
