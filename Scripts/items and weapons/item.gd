extends Area2D

@export var item_type : ItemType.type

func _on_body_entered(body):
	# if the object has the method picked_up_item(),
	# it is assumed to be the player
	if body is Player:
		body.picked_up_item(item_type)
	
	# removes the item from the screen
	get_parent().queue_free()
