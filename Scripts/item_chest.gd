extends Area2D

# object references
const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var open_sound = $open_sound

# variables
var item

# when a player enters the area
func _on_body_entered(body):
	if body is Player:
		# create a random item spawner
		var random_item = RANDOM_ITEM_SPAWNER.instantiate()
		random_item.position = position
		get_parent().add_child(random_item)
		item = random_item
		# play the animation
		animated_sprite.play("default")
		# start the timer
		timer.start(4.0/10.0)
		# play the opening sound
		open_sound.play()

# when a knife enters the area
func _on_area_entered(area):
	if area is Knife:
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

# when the timer ends, spawn an item and remove the chest
func _on_timer_timeout():
	item.spawn_item()
	queue_free()
