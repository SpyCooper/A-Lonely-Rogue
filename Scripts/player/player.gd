extends CharacterBody2D

class_name Player

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_spawn_down = $AttackSpawnDown
@onready var attack_spawn_up = $AttackSpawnUp
@onready var attack_spawn_left = $AttackSpawnLeft
@onready var attack_spawn_right = $AttackSpawnRight
@onready var death_timer = $DeathTimer
@onready var hud = %HUD

# constants
const KNIFE_SPEED = 150.0
const PLAYER_HEALTH_MAX = 10

# variables
var lastMove = "default"
var attacks_per_second = 1
var attack_damage = 1
var time_to_fire = 0.0
var time_to_fire_max = 1.0
var player_health = 6
var speed = 100.0
var number_of_keys = 0

# upgrade variables
var poisoned_blade = false
var shadow_blade = false
var glass_blade = false
var shadow_flame_blade = false
var dust_blade = false
var triple_blades = false
var shadow_heart = false

var current_type : BladeType.blade_type = BladeType.blade_type.default


var knife_scene = load("res://Scenes/knife.tscn")

# runs on start
func _ready():
	attacks_per_second = 1
	time_to_fire_max = time_to_fire_max / attacks_per_second

# runs on every frame
func _process(delta):
	# if the time to fire is above 0, it reduces the timer
	if time_to_fire > 0:
		time_to_fire -= delta

# runs on a set interval (fixed_update)
func _physics_process(delta):
	# controls player movement and normalizes the vector
	var direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	direction.normalized()
	velocity = direction * speed
	
	# controls the animations for the movement
	if direction.y == -1:
		animated_sprite.play("move_up")
		lastMove = "move_up"
	elif direction.y == 1:
		animated_sprite.play("move_down")
		lastMove = "move_down"
	elif direction.x < 0:
		animated_sprite.play("move_left")
		lastMove = "move_left"
	elif direction.x > 0:
		animated_sprite.play("move_right")
		lastMove = "move_right"
	else:
		if lastMove == "move_right":
			animated_sprite.play("idle_right")
		elif lastMove == "move_left":
			animated_sprite.play("idle_left")
		elif lastMove == "move_up":
			animated_sprite.play("idle_up")
		else:
			animated_sprite.play("idle_down")
	
	# moves the player
	move_and_slide()
	
	# controls throwing knives
	if Input.is_action_pressed("Attack"):
		# checks to see if the player can fire
		if time_to_fire <= 0:
			# checks to see which direction is the click was 
			var click_position = get_global_mouse_position() - position
			var click_position_normalized = click_position.normalized()
			var attack_instance = knife_scene.instantiate()
			
			# spawns a knife at that position
			attack_instance.position = position + click_position_normalized*3
			attack_instance.look_at(get_global_mouse_position())
			attack_instance.spawned(click_position_normalized, current_type, self)
			get_parent().add_child(attack_instance)
			
			# resets the time to fire
			time_to_fire = time_to_fire_max

# runs when an enemy hits the player
func player_take_damage():
	player_adjust_health(-1)

# when the death_timer runs out, the scene resets
func _on_timer_timeout():
	get_tree().reload_current_scene()
	Engine.time_scale = 1

# runs when an item is picked up
func picked_up_item(item):
	# there is probably a better way to do this but this will work for now
	# check the enum in item.gd for the numbers
	if item == ItemType.type.temp:
		print("picked up temp item")
	elif item == ItemType.type.health_2:
		if shadow_heart == false:
			player_adjust_health(2)
	elif item == ItemType.type.health_1:
		if shadow_heart == false:
			player_adjust_health(1)
	elif item == ItemType.type.poisoned_blades:
		hud.display_text("Aquired Poisoned Blades!", "Blades damage enemies after a short time for light damage.")
		poisoned_blade = true
		current_type = BladeType.blade_type.posioned
	elif item == ItemType.type.speed_boots:
		speed += 25
		hud.display_text("Aquired Speed Boots!", "You run faster.")
	elif item == ItemType.type.quick_blades:
		attacks_per_second += 1
		calculate_attack_speed()
		hud.display_text("Aquired Quicker Blades!", "Blades can be thrown faster.")
	elif item == ItemType.type.shadow_flame:
		shadow_flame_blade = true
		current_type = BladeType.blade_type.shadow_flame
		hud.display_text("Aquired Shadowflame!", "Blades damage enemies after a time for moderate damage.")
	elif item == ItemType.type.shadow_blade:
		shadow_blade = true
		current_type = BladeType.blade_type.shadow
		hud.display_text("Aquired Shadow Blades!", "Blades do increased damage.")
	elif item == ItemType.type.key:
		number_of_keys += 1
		hud.display_text("Aquired a key!", "Use it to open a locked door!")
	elif item == ItemType.type.shadow_heart:
		shadow_heart = true
		hud.refresh_hearts(player_health, shadow_heart)
		hud.display_text("Aquired the shadow heart!", "You follow the path of darkness now...")

func calculate_attack_speed():
	time_to_fire_max = time_to_fire_max / attacks_per_second

func player_adjust_health(change : int):
	if(player_health + change > PLAYER_HEALTH_MAX):
		player_health = PLAYER_HEALTH_MAX
	else:
		player_health += change
	hud.refresh_hearts(player_health, shadow_heart)
	if player_health <= 0:
		Engine.time_scale = 0.5
		death_timer.start()

func get_current_weapons():
	var current_blades = []
	if poisoned_blade == true:
		current_blades += [BladeType.blade_type.posioned]
	if shadow_flame_blade == true:
		current_blades += [BladeType.blade_type.shadow_flame]
	if shadow_blade == true:
		current_blades += [BladeType.blade_type.shadow]
	return current_blades

func killed_enemy():
	if shadow_heart == true:
		player_adjust_health(1)
