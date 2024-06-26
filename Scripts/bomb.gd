extends Node2D

# object references
@onready var life_time_timer = $life_time_timer
@onready var animated_sprite = $AnimatedSprite2D
@onready var fuse_sound = $fuse_sound
const BOMB_EXPLOSION = preload("res://Scenes/bomb_explosion.tscn")

# on ready
func _ready():
	# start the life time timer
	life_time_timer.start()
	# play the animation
	animated_sprite.play("default")
	# play the fuse sound
	fuse_sound.play()

# when the life time timer ends
func _on_life_time_timer_timeout():
	# spawn in the explosion
	var explosion = BOMB_EXPLOSION.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	# remove the bomb
	queue_free()
