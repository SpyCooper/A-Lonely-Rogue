extends Area2D

enum type
{
	temp,
	health_2,
	health_1,
	poisoned_blades,
	speed_boots,
	quick_blades,
}

@export var item_type : type

func _on_body_entered(body):
	# if the object has the method picked_up_item(),
	# it is assumed to be the player
	if body.get_name() == "Player":
		body.picked_up_item(item_type)
	
	# removes the item from the screen
	get_parent().queue_free()
