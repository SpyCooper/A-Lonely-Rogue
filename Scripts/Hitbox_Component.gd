extends Area2D

@export var health_component : HealthComponent

func damage(attack: Knife):
	if health_component:
		health_component.damage(attack)
