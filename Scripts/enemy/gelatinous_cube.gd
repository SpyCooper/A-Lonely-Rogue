extends Enemy

enum spawn_location
{
	top,
	bottom,
	left,
	right
}


@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var spawn_timer = $Spawn_timer
@onready var spawn_freeze_timer = $Spawn_freeze_timer

@onready var spawner_top = $Spawner_top
@onready var spawner_bottom = $Spawner_bottom
@onready var spawner_left = $Spawner_left
@onready var spawner_right = $Spawner_right
const GREEN_SLIME = preload("res://Scenes/enemies/green_slime.tscn")
@onready var animated_top = $animated_top
@onready var animated_bottom = $animated_bottom
@onready var animated_left = $animated_left
@onready var animated_right = $animated_right

var random_number_generator = RandomNumberGenerator.new()

var target_position
var current_direction : look_direction
var plaing_hit_animation = false
var can_attack = false
var dying = false
var spawning = false
var can_move = true

var slime_to_be_spawned = []

func _ready():
	speed = 0.25
	health = 30
	sleep()
	player = Events.player
	animated_bottom.hide()
	animated_left.hide()
	animated_right.hide()
	animated_top.hide()
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
			spawn_in()
			attack_timer.start()
		else:
			sleep()
	)

# called every frame
func _physics_process(_delta):
	if player_in_room && !dying && !spawning:
		if can_attack:
			spawn_slimes()
		
		# follows the player
		if player && can_move:
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_look_direction(target_position)
			
			# flips the direction of the slime based on the if the target is on the left or right
			if current_direction == look_direction.left :
				if animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_up" || animated_sprite.animation == "hit_down" :
					var frame = animated_sprite.frame
					animated_sprite.play("hit_left")
					animated_sprite.frame = frame
				elif plaing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_left")
					plaing_hit_animation = false
			elif current_direction == look_direction.right:
				if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_up" || animated_sprite.animation == "hit_down":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame
				elif plaing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_right")
					plaing_hit_animation = false
			elif current_direction == look_direction.up:
				if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_down":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_up")
					animated_sprite.frame = frame
				elif plaing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_up")
					plaing_hit_animation = false
			elif current_direction == look_direction.down:
				if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_up":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_down")
					animated_sprite.frame = frame
				elif plaing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_down")
					plaing_hit_animation = false
			# moves the slime
			if position.distance_to(player_position) > 5.0:
					move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	if !spawning && !dying:
		health -= damage
		if current_direction == look_direction.left:
			animated_sprite.play("hit_left")
		elif current_direction == look_direction.right:
			animated_sprite.play("hit_right")
		elif current_direction == look_direction.up:
			animated_sprite.play("hit_up")
		elif current_direction == look_direction.down:
			animated_sprite.play("hit_down")
		plaing_hit_animation = true
		if health <= 0:
			enemy_slain()

func get_animated_sprite():
	return animated_sprite

func spawn_slimes():
	var random_spawns = random_number_generator.randi_range(1, 3)
	var top_used = false;
	var bottom_used = false;
	var right_used = false;
	var left_used = false;
	for spawn in random_spawns:
		var random_pos = random_number_generator.randi_range(0, 3)
		if random_pos == 0 && top_used == false:
			slime_to_be_spawned += [spawn_location.top]
			animated_top.show()
			animated_top.play("default")
			top_used = true
		elif random_pos == 1 && right_used == false:
			slime_to_be_spawned += [spawn_location.right]
			animated_right.show()
			animated_right.play("default")
			right_used = true
		elif random_pos == 2 && left_used == false:
			slime_to_be_spawned += [spawn_location.left]
			animated_left.show()
			animated_left.play("default")
			left_used = true
		elif random_pos == 3 && bottom_used == false:
			slime_to_be_spawned += [spawn_location.bottom]
			animated_bottom.show()
			animated_bottom.play("default")
			bottom_used = true
	
	spawn_freeze_timer.start()
	attack_timer.start()
	can_attack = false
	can_move = false
	animated_sprite.play("spawn_slime")

func _on_attack_timer_timeout():
	can_attack = true

func enemy_slain():
	dying = true
	death_timer.start()
	animated_sprite.play("death")

func _on_death_timer_timeout():
	player.killed_enemy()
	queue_free()

func spawn_in():
	spawning = true
	animated_sprite.play("spawning")
	spawn_timer.start()

func _on_spawn_timer_timeout():
	spawning = false

func _on_spawn_freeze_timer_timeout():
	can_move = true
	for spawn in slime_to_be_spawned:
		var green_slime = GREEN_SLIME.instantiate()
		get_parent().add_child(green_slime)
		green_slime.spawned_in_room()
		var vect = Vector2(1,1)
		if spawn == spawn_location.top:
			green_slime.global_position = spawner_top.global_position
			vect = Vector2(0.0,1.0)
		elif spawn == spawn_location.right:
			green_slime.global_position = spawner_right.global_position
			vect = Vector2(1.0,0.0)
		elif spawn == spawn_location.left:
			green_slime.global_position = spawner_left.global_position
			vect = Vector2(-1.0,0.0)
		elif spawn == spawn_location.bottom:
			green_slime.global_position = spawner_bottom.global_position
			vect = Vector2(0.0,1.0)
		
		var collision = green_slime.move_and_collide(vect)
		if collision != null:
			green_slime.despawn()
	
	animated_bottom.hide()
	animated_left.hide()
	animated_right.hide()
	animated_top.hide()
	
	slime_to_be_spawned = []
