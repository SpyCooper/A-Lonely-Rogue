extends Node2D

# object references
@onready var time_between_knife_throws_timer = $time_between_knife_throws_timer
@onready var life_time_timer = $life_time_timer
@onready var animated_sprite = $AnimatedSprite2D
@onready var leave_animation_timer = $leave_animation_timer
@onready var smoke_bomb_sound = $smoke_bomb_sound
@onready var woosh_sound = $woosh_sound
const TINY_ROGUE_KNIFE = preload("res://Scenes/pets/tiny_rogue_knife.tscn")
const TINY_ROGUE_LEAVE_SOUND = preload("res://Scenes/pets/tiny_rogue_leave_sound.tscn")

# variables
var can_spawn_knife = true
var can_throw_knives = true
var angle = 0.0

# when spawned
func spawned():
	# start the knife throws timer
	time_between_knife_throws_timer.start()
	# start the life time timer
	life_time_timer.start()

func _physics_process(_delta):
	# circle around the tiny rogue
	angle += 0.10
	# if the tiny rogue can spawn a knife and can throw a knife
	if can_spawn_knife && can_throw_knives:
		# spawn a knife
		var direction = Vector2(cos(angle), sin(angle))
		var direction_normalized = direction.normalized()
		var blade_instance = TINY_ROGUE_KNIFE.instantiate()
		blade_instance.global_position = animated_sprite.global_position
		blade_instance.spawned_tiny_knife(direction_normalized)
		get_parent().add_child(blade_instance)
		# disable can spawn
		can_spawn_knife = false
		# play the woosh sound
		woosh_sound.play()

# when the knife throws timer ends
func _on_time_between_knife_throws_timer_timeout():
	# allow a knife to be thrown
	can_spawn_knife = true

# when the life time timer ends
func _on_life_time_timer_timeout():
	# do not allow knives to be thrown
	can_throw_knives = false
	# plat the leave animation and sound
	animated_sprite.play("leaving")
	smoke_bomb_sound.play()
	# start the leave animation timer
	leave_animation_timer.start()
	# spawn the tiny rogue leave sound
	var sound = TINY_ROGUE_LEAVE_SOUND.instantiate()
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)

# when the leave animation timer ends
func _on_leave_animation_timer_timeout():
	# remove the tiny rogue
	queue_free()
