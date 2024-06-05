extends Area2D

# if a knife enters a body, print it
func _on_body_entered(body):
	if body is Knife:
		print("knife hit")
