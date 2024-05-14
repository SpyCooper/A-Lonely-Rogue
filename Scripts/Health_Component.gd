extends Node2D

class_name HealthComponent

@export var MAX_HEALTH := 3
var health: float

func _ready():
	health = MAX_HEALTH

func take_damage(attack: Knife):
	health -= attack.attack_damage
	
	if health <= 0:
		get_parent().queue_free()
