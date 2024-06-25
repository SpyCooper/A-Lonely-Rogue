extends Area2D

class_name Pet

var angle = 0.0
var distance_from_player = 15
var max_health
var health

func _ready():
	max_health = 5
	health = max_health
	position += Vector2(0, distance_from_player)

func _physics_process(_delta):
	# circles around the player
	angle += 0.1
	global_position = Events.player.global_position + Vector2.RIGHT.rotated(angle) * distance_from_player
	look_at(Events.player.position)

func take_damage(damage):
	health -= damage
	if health <= 0:
		get_parent().protective_charm_spawn_died()
		queue_free()

func reset_hp():
	health = max_health

func set_pet_hp(hp):
	health = hp

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(1, 0, true)

