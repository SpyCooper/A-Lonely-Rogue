extends Node2D

# gets references to the sprites on the floor for the room
@onready var icon_up = $icon_up
@onready var icon_down = $icon_down
@onready var icon_left = $icon_left
@onready var icon_right = $icon_right

func show_sprite_top():
	icon_up.play("pulsing")
func inactive_sprite_top():
	icon_up.play("non_pulsing")
func hide_sprite_top():
	icon_up.play("none")

func show_sprite_bottom():
	icon_down.play("pulsing")
func inactive_sprite_bottom():
	icon_down.play("non_pulsing")
func hide_sprite_bottom():
	icon_down.play("none")

func show_sprite_right():
	icon_right.play("pulsing")
func inactive_sprite_right():
	icon_right.play("non_pulsing")
func hide_sprite_right():
	icon_right.play("none")

func show_sprite_left():
	icon_left.play("pulsing")
func inactive_sprite_left():
	icon_left.play("non_pulsing")
func hide_sprite_left():
	icon_left.play("none")
