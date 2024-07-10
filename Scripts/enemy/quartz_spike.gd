extends Node2D

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var enter_animation_timer = $enter_animation_timer
@onready var attack_animation_timer = $attack_animation_timer
@onready var exit_animation_timer = $exit_animation_timer
@onready var marker = $Marker2D
const QUARTZ_SPIKE_DAMAGE_AREA = preload("res://Scenes/enemies/quartz_spike/quartz_spike_damage_area.tscn")
@onready var damage_player = $DamagePlayer
@onready var attack_sound = $attack_sound
@onready var enter_sound = $enter_sound

# variables
var damage_area_scene

# on ready
func _ready():
	# starts the enter animation timer
	enter_animation_timer.start()
	# plays the enter animation
	animated_sprite.play("enter")
	# adjusts the scene's position
	position -= animated_sprite.position
	
	enter_sound.play()


# when the enter animation timer ends
func _on_enter_animation_timer_timeout():
	# starts the attack animation timer
	attack_animation_timer.start()
	# plays the attack animation
	animated_sprite.play("attack")
	# plays the attack sound
	attack_sound.play()
	# spawns the damage area
	damage_area_scene = QUARTZ_SPIKE_DAMAGE_AREA.instantiate()
	#damage_area_scene = VINE_SPIN_DAMAGE_PLAYER.instantiate()
	damage_player.add_child(damage_area_scene)
	damage_area_scene.position = damage_player.position

# when the attack animation timer ends
func _on_attack_animation_timer_timeout():
	# remove the damage area
	damage_area_scene.queue_free()
	# starts the exit animation timer
	exit_animation_timer.start()
	# plays the exit animation
	animated_sprite.play("exit")

# when the exit animation timer ends
func _on_exit_animation_timer_timeout():
	# remove the scene
	queue_free()

func set_spawn_position(new_position):
	global_position = new_position - animated_sprite.position
