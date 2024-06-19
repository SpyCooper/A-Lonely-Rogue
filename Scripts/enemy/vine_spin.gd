extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var enter_animation_timer = $enter_animation_timer
@onready var attack_animation_timer = $attack_animation_timer
@onready var exit_animation_timer = $exit_animation_timer
const VINE_SPIN_DAMAGE_PLAYER = preload("res://Scenes/enemies/vine_spin/vine_spin_damage_player.tscn")
var damage_area_scene
@onready var marker = $Marker2D
@onready var attack_sound = $attack_sound

func _ready():
	enter_animation_timer.start()
	animated_sprite.play("enter")
	position -= animated_sprite.position


func _on_enter_animation_timer_timeout():
	attack_animation_timer.start()
	animated_sprite.play("attack")
	attack_sound.play()
	damage_area_scene = VINE_SPIN_DAMAGE_PLAYER.instantiate()
	add_child(damage_area_scene)
	damage_area_scene.position = marker.position


func _on_attack_animation_timer_timeout():
	damage_area_scene.queue_free()
	exit_animation_timer.start()
	animated_sprite.play("exit")


func _on_exit_animation_timer_timeout():
	queue_free()
