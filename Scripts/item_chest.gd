extends Area2D

const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer

var item

func _on_body_entered(body):
	if body is Player:
		var random_item = RANDOM_ITEM_SPAWNER.instantiate()
		random_item.position = position
		get_parent().add_child(random_item)
		item = random_item
		animated_sprite.play("default")
		timer.start(4.0/10.0)

func _on_area_entered(area):
	if area is Knife:
		var random_item = RANDOM_ITEM_SPAWNER.instantiate()
		random_item.position = position
		item = random_item
		get_parent().add_child(random_item)
		animated_sprite.play("default")
		timer.start(4.0/10.0)


func _on_timer_timeout():
	item.spawn_item()
	queue_free()
