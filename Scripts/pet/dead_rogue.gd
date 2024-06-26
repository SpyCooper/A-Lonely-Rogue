extends Pet

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer = $attack_timer
@onready var woosh_sound = $woosh_sound
@onready var enter_sound = $enter_sound
const DEAD_ROGUE_LEAVE_SOUND = preload("res://Scenes/pets/dead_rogue_leave_sound.tscn")
const TINY_ROGUE_KNIFE = preload("res://Scenes/pets/tiny_rogue_knife.tscn")

# variables
var room_ref = null
var can_throw = false

func _ready():
	# sets the pet variables
	max_health = 1
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
	pass

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the rogue to attack
	can_throw = true

# remove the pet
func kill_pet():
	# spawn the tiny rogue leave sound
	var sound = DEAD_ROGUE_LEAVE_SOUND.instantiate()
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)
	# removes the pet
	queue_free()
