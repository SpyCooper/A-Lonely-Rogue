extends Node2D

@onready var move_label = $Move_label
@onready var shoot_label = $Shoot_label

const FILE_PATH = "user://settings.ini"
var config = ConfigFile.new()

func _ready():
	move_label.text = "Press " + InputMap.action_get_events("MoveUp")[0].as_text() + " " + InputMap.action_get_events("MoveLeft")[0].as_text() + " " + InputMap.action_get_events("MoveDown")[0].as_text() + " " + InputMap.action_get_events("MoveRight")[0].as_text() + " to move"
	shoot_label.text = "Press " + InputMap.action_get_events("Attack")[0].as_text() + " to throw knives"
