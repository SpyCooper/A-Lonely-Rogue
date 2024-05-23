extends ColorRect

func _ready():
	hide()

func _input(event):
	## make an actual pause menu
	if event.is_action_pressed("Pause"):
		show()
		Engine.time_scale = 0.0

func _on_close_options_button_pressed():
	hide()
	Engine.time_scale = 1.0
