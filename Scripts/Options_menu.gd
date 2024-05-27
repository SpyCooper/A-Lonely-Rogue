extends Control

@onready var master_sound_label = $Panel/Sound_sliders/master_sound/master_sound_label
@onready var master_sound_slider = $Panel/Sound_sliders/master_sound/master_sound_slider
@onready var music_sound_slider = $Panel/Sound_sliders/music_sound/music_sound_slider
@onready var music_sound_label = $Panel/Sound_sliders/music_sound/music_sound_label
@onready var sfx_sound_slider = $Panel/Sound_sliders/sfx_sound/sfx_sound_slider
@onready var sfx_sound_label = $Panel/Sound_sliders/sfx_sound/sfx_sound_label

@onready var awaiting_input = $Panel/Awaiting_input
@onready var up_button = $Panel/KeyBinds/Move_up/up_button
@onready var down_button = $Panel/KeyBinds/Move_down/down_button
@onready var left_button = $Panel/KeyBinds/Move_left/left_button
@onready var right_button = $Panel/KeyBinds/Move_right/right_button
@onready var throw_button = $Panel/KeyBinds/Throw/throw_button

var action
var checking_input = false

func _ready():
	awaiting_input.hide()
	hide()
	check_button_inputs()
	set_process_unhandled_input(false)

func _on_close_options_button_pressed():
	hide()

func _on_master_sound_slider_value_changed(value):
	# adjust master sound
	master_sound_label.text = "Master Volume: " + str(master_sound_slider.value)

func _on_music_sound_slider_value_changed(value):
	# adjust music sound
	music_sound_label.text = "Music Volume: " + str(music_sound_slider.value)

func _on_sfx_sound_slider_value_changed(value):
	# adjust SFX sound
	sfx_sound_label.text = "SFX Volume: " + str(sfx_sound_slider.value)

func _on_up_button_pressed():
	awaiting_input.show()
	action = "MoveUp"
	checking_input = true

func _on_down_button_pressed():
	awaiting_input.show()
	action = "MoveDown"
	checking_input = true

func _on_left_button_toggled(toggled_on):
	awaiting_input.show()
	action = "MoveLeft"
	checking_input = true

func _on_right_button_pressed():
	awaiting_input.show()
	action = "MoveRight"
	checking_input = true

func _on_throw_button_pressed():
	awaiting_input.show()
	action = "Attack"
	checking_input = true


func _input(event):
	if checking_input == true:
		if event is InputEventKey:
			if event.is_pressed() && event.as_text_key_label() != "Escape":
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
				checking_input = false
				check_button_inputs()
				awaiting_input.hide()
		elif event is InputEventMouseButton:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			checking_input = false
			check_button_inputs()
			awaiting_input.hide()

func check_button_inputs():
	up_button.text = "%s" % InputMap.action_get_events("MoveUp")[0].as_text()
	down_button.text = "%s" % InputMap.action_get_events("MoveDown")[0].as_text()
	left_button.text = "%s" % InputMap.action_get_events("MoveLeft")[0].as_text()
	right_button.text = "%s" % InputMap.action_get_events("MoveRight")[0].as_text()
	throw_button.text = "%s" % InputMap.action_get_events("Attack")[0].as_text()
