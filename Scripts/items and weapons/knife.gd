extends Area2D

class_name Knife

# sets the effects the knives can have
const POISON_EFFECT = preload("res://Scenes/status_effects/poison_effect.tscn")
const SHADOW_FLAME_EFFECT = preload("res://Scenes/status_effects/shadow_flame_effect.tscn")
const DUST_BLADE_EFFECT = preload("res://Scenes/status_effects/dust_blade_effect.tscn")
const GLASS_SHRAPNEL = preload("res://Scenes/status_effects/glass_shrapnel.tscn")
@onready var lifetime_timer = $lifetime_timer
var timer_started = false

# variables
var move_direction
var speed = 150
var type : BladeType.blade_type = BladeType.blade_type.default
var player_ref
var base_damage = 1
var attack_identifer
const KNIFE_HIT = preload("res://Scenes/knife_hit.tscn")

# this is called when the player is clicks
func spawned(click_position, blade_type, player, current_attack_identifier, knife_speed_bonus):
	# $AnimatedSprite2D has to be called here since 
	# it is loaded before the object exists in the scene
	var animated_sprite = $AnimatedSprite2D
	change_blade_type(animated_sprite, blade_type)
	player_ref = player
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = click_position
	look_at(position + move_direction)
	attack_identifer = current_attack_identifier
	# adds speed to the knife based on knife speed bonus
	speed += knife_speed_bonus

# runs on every frane
func _process(delta):
	if Engine.time_scale != 0.0:
		# moves the knife based on the thrown direction
		position += move_direction * speed * delta
		# starts the lifetime timer if it hasn't started
		if !timer_started:
			# starts the lifetime timer
			lifetime_timer.start()
			timer_started = true

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# if the object has the method take_damage(), it will run it
	if body is Enemy && !body.is_spawning() && !body.is_dying():
		# sets knife damage to base_damage
		var damage = base_damage
		# gets the current types of knives the player has
		var current_blade_types = player_ref.get_current_weapons()
		# for each knife type
		for blade_type in current_blade_types:
			# applies the effect of the poisoned blade
			if blade_type == BladeType.blade_type.posioned:
				if body.is_poisoned() == false:
					body.add_child(POISON_EFFECT.instantiate())
			# applies the effect of the shadow flame blade
			elif blade_type == BladeType.blade_type.shadow_flame:
				if body.is_shadow_flamed() == false:
					body.add_child(SHADOW_FLAME_EFFECT.instantiate())
			# applies the effect of the shadow blade
			elif blade_type == BladeType.blade_type.shadow:
				damage += 1
			# applies the effect of the dust blade
			elif blade_type == BladeType.blade_type.dust:
				body.add_child(DUST_BLADE_EFFECT.instantiate())
		# check if the player has the emerald skull
		if player_ref.has_emerald_skull():
			damage += 1
		# the knife deals damage to the enemies hit
		body.take_damage(damage, attack_identifer, false)
	# plays the knife hit sound
	var knife_hit_sound = KNIFE_HIT.instantiate()
	knife_hit_sound.position = position
	get_tree().current_scene.add_child(knife_hit_sound)
	# if the player has glass blade
	for blade_type in player_ref.get_current_weapons():
		if blade_type == BladeType.blade_type.glass:
			# spawn the glass blade explosion at the position of the knife
			var glass_explosion_spawn = GLASS_SHRAPNEL.instantiate()
			glass_explosion_spawn.position = position
			get_tree().current_scene.add_child(glass_explosion_spawn)
			glass_explosion_spawn.emitting = true
	# removes the knife from the screen
	queue_free()

# changes the blade type based on the last aquired blade
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
	elif blade_type == BladeType.blade_type.sleek:
		animated_sprite.play("sleek_blade")

# when the lifetime timer ends, remove the knife
func _on_lifetime_timer_timeout():
	queue_free()
