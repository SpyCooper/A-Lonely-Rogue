extends Node2D

const TINY_ROGUE_KNIFE = preload("res://Scenes/pets/tiny_rogue_knife.tscn")
var can_spawn_knife = true
var can_throw_knives = true
var angle = 0.0
@onready var time_between_knife_throws_timer = $time_between_knife_throws_timer
@onready var life_time_timer = $life_time_timer
@onready var animated_sprite = $AnimatedSprite2D
@onready var leave_animation_timer = $leave_animation_timer

func _ready():
	time_between_knife_throws_timer.start()
	life_time_timer.start()

func _physics_process(_delta):
	# circles around the player
	angle += 0.10
	if can_spawn_knife && can_throw_knives:
		var direction = Vector2(cos(angle), sin(angle))
		var direction_normalized = direction.normalized()
		var blade_instance = TINY_ROGUE_KNIFE.instantiate()
		blade_instance.global_position = animated_sprite.global_position
		blade_instance.spawned_tiny_knife(direction_normalized)
		get_parent().add_child(blade_instance)
		can_spawn_knife = false

func _on_time_between_knife_throws_timer_timeout():
	can_spawn_knife = true

func _on_life_time_timer_timeout():
	can_throw_knives = false
	animated_sprite.play("leaving")
	leave_animation_timer.start()

func _on_leave_animation_timer_timeout():
	queue_free()
