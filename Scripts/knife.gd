extends Area2D

class_name Knife

const POISON_EFFECT = preload("res://Scenes/status_effects/poison_effect.tscn")
const SHADOW_FLAME_EFFECT = preload("res://Scenes/status_effects/shadow_flame_effect.tscn")

# variables
var move_direction
var speed = 150
var type : BladeType.blade_type = BladeType.blade_type.default
var player_ref
# this is called when the player is clicks
func spawned(click_position, blade_type, player):
	# $AnimatedSprite2D has to be called here since 
	# it is loaded before the object exists in the scene
	var animated_sprite = $AnimatedSprite2D
	change_blade_type(animated_sprite, blade_type)
	player_ref = player
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = click_position

# runs on every frane
func _process(delta):
	# moves the knife based on the thrown direction
	position += move_direction * speed * delta

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# if the object has the method hit(), it will run it
	if body.has_method("hit"):
		var damage = 1
		var current_blade_types = player_ref.get_current_weapons()
		for blade_type in current_blade_types:
			if blade_type == BladeType.blade_type.posioned:
				if body.is_poisoned() == false:
					body.add_child(POISON_EFFECT.instantiate())
			elif blade_type == BladeType.blade_type.shadow_flame:
				if body.is_shadow_flamed() == false:
					body.add_child(SHADOW_FLAME_EFFECT.instantiate())
			elif blade_type == BladeType.blade_type.shadow:
				damage += 1
		body.hit(damage)
	
	# removes the knife from the screen
	queue_free()

func change_blade_type(animated_sprite, blade_type):
	if blade_type == BladeType.blade_type.shadow_flame:
		animated_sprite.play("shadow_flame_blade")
	elif blade_type == BladeType.blade_type.shadow:
		animated_sprite.play("shadow_blade")
	elif blade_type == BladeType.blade_type.glass:
		animated_sprite.play("glass_blade")
	elif blade_type == BladeType.blade_type.dust:
		animated_sprite.play("dust_blade")
	elif blade_type == BladeType.blade_type.posioned:
		animated_sprite.play("poison_blade")
