extends Area2D

func _on_body_entered(body):
	# if the object has the method picked_up_item(),
	# it is assumed to be the player
	if body.has_method("picked_up_item"):
		body.picked_up_item("temp")
	
	# removes the knife from the screen
	get_parent().queue_free()
