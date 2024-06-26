extends Pet

const TINY_ROGUE_KNIFE = preload("res://Scenes/pets/tiny_rogue_knife.tscn")
var room_ref = null
var can_throw = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer = $attack_timer
@onready var woosh_sound = $woosh_sound
@onready var enter_sound = $enter_sound
@onready var hit_sound = $hit_sound
const TINY_ROGUE_LEAVE_SOUND = preload("res://Scenes/pets/tiny_rogue_leave_sound.tscn")
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")

func _ready():
	# sets the pet variables
	max_health = 3
	health = max_health
	distance_from_player = 20
	speed = .05
	position += Vector2(0, distance_from_player)
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		# track the current_room
		room_ref = room
	)
	# plays the pet enter sound
	enter_sound.play()
	# start the attack timer
	attack_timer.start()

# called on set intervals
func _physics_process(_delta):
	# circles around the player
	angle += speed
	global_position = Events.player.global_position + Vector2.RIGHT.rotated(angle) * distance_from_player
	## does not look at the player like the charms do
	# if the player is in a room
	if room_ref != null:
		# if the room has enemies
		if room_ref.is_enemies():
			# if the rogue can throw
			if can_throw:
				# throw a knife at an enemy
				var blade_instance = TINY_ROGUE_KNIFE.instantiate()
				blade_instance.position = self.global_position
				var target = room_ref.get_enemies_in_room()[0]
				for enemy in room_ref.get_enemies_in_room():
					if enemy != null:
						target = enemy
				var direction = target.get_animated_sprite().global_position - blade_instance.global_position
				direction = direction.normalized()
				blade_instance.spawned_tiny_knife(direction)
				get_tree().current_scene.add_child(blade_instance)
				# disable can spawn
				can_throw = false
				# start the attack timer
				attack_timer.start()
				# play the attack sound
				woosh_sound.play()

# when the pet takes damage
func take_damage(damage):
	# remove health
	health -= damage
	# if health is above 0
	if health > 0:
		# plays the hit animation
		animated_sprite.material.shader = null
		animated_sprite.material.shader = HIT_SHADER
		hit_flash_animation_player.play("hit_flash")
		hit_flash_animation_timer.start()
		# plays the hit sound
		hit_sound.play()
	# if health is 0
	if health <= 0:
		# tell the player the pet died
		get_parent().pet_died(ItemType.type.magically_trapped_rogue)
		# remove the pet
		kill_pet()

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the rogue to attack
	can_throw = true

# remove the pet
func kill_pet():
	# spawn the tiny rogue leave sound
	var sound = TINY_ROGUE_LEAVE_SOUND.instantiate()
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)
	# removes the pet
	queue_free()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
