extends Node2D

@onready var door_visual_up = $"../DoorVisualUp"
@onready var door_visual_right = $"../DoorVisualRight"
@onready var door_visual_down = $"../DoorVisualDown"
@onready var door_visual_left = $"../DoorVisualLeft"

@onready var up_key_sprite = $Key_check_up/AnimatedSprite2D
@onready var down_key_sprite = $Key_check_down/AnimatedSprite2D
@onready var left_key_sprite = $Key_check_left/AnimatedSprite2D
@onready var right_key_sprite = $Key_check_right/AnimatedSprite2D

var door_up_locked = false
var door_down_locked = false
var door_left_locked = false
var door_right_locked = false

func _ready():
	if door_visual_up != null:
		door_up_locked = door_visual_up.is_locked()
	if door_visual_down != null:
		door_down_locked = door_visual_down.is_locked()
	if door_visual_left != null:
		door_left_locked = door_visual_left.is_locked()
	if door_visual_right != null:
		door_right_locked = door_visual_right.is_locked()
	reset_key_sprites()

func reset_key_sprites():
	if door_up_locked == false:
		up_key_sprite.hide()
	if door_down_locked == false:
		down_key_sprite.hide()
	if door_left_locked == false:
		left_key_sprite.hide()
	if door_right_locked == false:
		right_key_sprite.hide()
