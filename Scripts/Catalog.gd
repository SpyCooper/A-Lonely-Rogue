extends Control

@onready var blue_slime_panel = $TabContainer/Monsters/Panels/Blue_slime_panel
@onready var green_slime_panel = $TabContainer/Monsters/Panels/Green_slime_panel

func _ready():
	hide()
	clear_panel()

func _on_blue_slime_pressed():
	clear_panel()
	blue_slime_panel.show()
	
func _on_green_slime_pressed():
	clear_panel()
	green_slime_panel.show()

func clear_panel():
	blue_slime_panel.hide()
	green_slime_panel.hide()
	
