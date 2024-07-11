extends Pet

var room_ref = null
var can_throw = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer = $attack_timer
@onready var enter_sound = $enter_sound
@onready var hit_sound = $hit_sound
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")
#const VOID_ORB_FRIENDLY = preload("res://Scenes/enemies/void_orb/void_orb_friendly.tscn")
# defines a random number generator
var rng = RandomNumberGenerator.new()

func _ready():
	# sets the pet variables
	max_health = 10
	health = max_health
	distance_from_player = 20
	speed = .06
	position += Vector2(0, distance_from_player)
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		# track the current_room
		room_ref = room
		# reset the attacks
		can_throw = false
		# start the attack timer
		attack_timer.start()
	)
	# plays the pet enter sound
	enter_sound.play()

# called on set intervals
func _physics_process(_delta):
	# circles around the player
	angle += speed
	global_position = Events.player.get_player_position() + Vector2.RIGHT.rotated(angle) * distance_from_player
	## does not look at the player like the charms do
	# if the player is in a room
	if room_ref != null:
		# if the room has enemies
		if room_ref.is_enemies():
			# if the rogue can throw
			if can_throw:
				attack()

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
	
	# removes the pet
	queue_free()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

func attack():
	var vec_x = rng.randf_range(0.1, 1)
	var pos_or_neg = rng.randi_range(-1, 1)
	vec_x = pos_or_neg * vec_x
	## y direction
	var vec_y = rng.randf_range(0.1, 1)
	pos_or_neg = rng.randi_range(-1, 1)
	vec_y = pos_or_neg * vec_y
	# normalize the movement vector
	var direction = Vector2(vec_x, vec_y).normalized()
	
	#if direction == Vector2(0,0):
		#direction = Vector2(0.5,0.5).normalized()
	## throw a knife at an enemy
	#var void_orb = VOID_ORB_FRIENDLY.instantiate()
	#get_tree().current_scene.add_child(void_orb)
	#void_orb.global_position = animated_sprite.global_position
	#void_orb.spawned(direction, true, false, true)
	
	# disable can spawn
	can_throw = false
	# start the attack timer
	attack_timer.start()
	# play the attack sound
