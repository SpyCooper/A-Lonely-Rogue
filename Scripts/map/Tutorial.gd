extends Node2D

# object references
@onready var move_label = $Move_label
@onready var shoot_label = $Shoot_label
@onready var active_items_label = $active_items_label

# on ready
func _ready():
	# shows the text for the movement controls
	move_label.text = "Press " + InputMap.action_get_events("MoveUp")[0].as_text() + " " + InputMap.action_get_events("MoveLeft")[0].as_text() + " " + InputMap.action_get_events("MoveDown")[0].as_text() + " " + InputMap.action_get_events("MoveRight")[0].as_text() + " to move"
	# shows the text for the attack control
	shoot_label.text = "Press " + InputMap.action_get_events("Attack")[0].as_text() + " to throw knives"
	# shows the text for the Use item control
	active_items_label.text = "Press " + InputMap.action_get_events("UseItem")[0].as_text() + " to use active items"
