extends Control

# audio object references
@onready var master_sound_label = $Panel/Sound_sliders/master_sound/master_sound_label
@onready var master_sound_slider = $Panel/Sound_sliders/master_sound/master_sound_slider
@onready var music_sound_slider = $Panel/Sound_sliders/music_sound/music_sound_slider
@onready var music_sound_label = $Panel/Sound_sliders/music_sound/music_sound_label
@onready var sfx_sound_slider = $Panel/Sound_sliders/sfx_sound/sfx_sound_slider
@onready var sfx_sound_label = $Panel/Sound_sliders/sfx_sound/sfx_sound_label

# keybinding object references
@onready var awaiting_input = $Panel/Awaiting_input
@onready var up_button = $Panel/KeyBinds/Move_up/up_button
@onready var down_button = $Panel/KeyBinds/Move_down/down_button
@onready var left_button = $Panel/KeyBinds/Move_left/left_button
@onready var right_button = $Panel/KeyBinds/Move_right/right_button
@onready var throw_button = $Panel/KeyBinds/Throw/throw_button
@onready var use_item_button = $"Panel/KeyBinds/Use Item/Use_item_button"
@onready var close_input_screen_text = $Panel/Awaiting_input/sub_text

# other object references
@onready var window_mode_label = $Panel/Screen_mode/window_mode_label
@onready var toggle_fullscreen_button = $Panel/Screen_mode/toggle_fullscreen_button

# variables
var action_queued
var checking_input = false

# on start
func _ready():
	# hide the screens
	awaiting_input.hide()
	hide()
	# disable input checking
	set_process_unhandled_input(false)
	# load in the keybindings
	load_keybindings_from_settings()
	# load in the audio settings
	load_audio_from_settings()
	# set the pause menu button
	close_input_screen_text.text = InputMap.action_get_events("Pause")[0].as_text() + " to quit"
	# set the window mode text
	set_window_mode_text()

# when the close button is pressed, hide the menu
func _on_close_options_button_pressed():
	hide()

# when the master sound slider is changed
func _on_master_sound_slider_value_changed(value):
	# save the volume
	ConfigFileManager.save_audio_setting("master_volume", value/10)
	# set the text
	master_sound_label.text = "Master Volume: " + str(value)

# when the music sound slider is changed
func _on_music_sound_slider_value_changed(value):
	# set the text
	music_sound_label.text = "Music Volume: " + str(value)
	# adjust the bus volume
	## NOTE: ConfigFileManager.gd does this too
	var sound_change
	if value != 0:
		sound_change = -3.0 * (10.0 - value)
	elif value == 0:
		sound_change = -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), sound_change)
	# save the setting
	ConfigFileManager.save_audio_setting("music_volume", value/10)

# when the SFX sound slider is changed
func _on_sfx_sound_slider_value_changed(value):
	# set the text
	sfx_sound_label.text = "SFX Volume: " + str(value)
	# adjust the bus volume
	## NOTE: ConfigFileManager.gd does this too
	var sound_change
	if value != 0:
		sound_change = -3.0 * (10.0 - value)
	elif value == 0:
		sound_change = -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effect"), sound_change)
	# save the setting
	ConfigFileManager.save_audio_setting("sfx_volume", value/10)

# when the up keybinding is pressed
func _on_up_button_pressed():
	action_queued = "MoveUp"
	input_screen_open()

# when the down keybinding is pressed
func _on_down_button_pressed():
	action_queued = "MoveDown"
	input_screen_open()

# when the left keybinding is pressed
func _on_left_button_pressed():
	action_queued = "MoveLeft"
	input_screen_open()

# when the right keybinding is pressed
func _on_right_button_pressed():
	action_queued = "MoveRight"
	input_screen_open()

# when the attack keybinding is pressed
func _on_throw_button_pressed():
	action_queued = "Attack"
	input_screen_open()

# when the use item keybinding is pressed
func _on_use_item_button_pressed():
	action_queued = "UseItem"
	input_screen_open()

# when an input is detected
func _input(event):
	# if the program is checking input
	if checking_input == true:
		# if the input is a key press
		if event is InputEventKey:
			# check if the event was pressed and is not the pause button
			if event.is_pressed() && event.as_text_key_label() != InputMap.action_get_events("Pause")[0].as_text():
				# add the keybinding to the controls
				InputMap.action_erase_events(action_queued)
				InputMap.action_add_event(action_queued, event)
				# close the awaiting input screen
				input_screen_close()
				# save the keybindings
				ConfigFileManager.save_keybindings(action_queued, event)
		# if the input is a mouse press
		elif event is InputEventMouseButton:
			# add the keybinding to the controls
			InputMap.action_erase_events(action_queued)
			InputMap.action_add_event(action_queued, event)
			# close the awaiting input screen
			input_screen_close()
			# save the keybindings
			ConfigFileManager.save_keybindings(action_queued, event)

# check what input is used for the controls
func check_button_inputs():
	up_button.text = "%s" % InputMap.action_get_events("MoveUp")[0].as_text()
	down_button.text = "%s" % InputMap.action_get_events("MoveDown")[0].as_text()
	left_button.text = "%s" % InputMap.action_get_events("MoveLeft")[0].as_text()
	right_button.text = "%s" % InputMap.action_get_events("MoveRight")[0].as_text()
	throw_button.text = "%s" % InputMap.action_get_events("Attack")[0].as_text()
	use_item_button.text = "%s" % InputMap.action_get_events("UseItem")[0].as_text()

# loads the keybindings from the settings
func load_keybindings_from_settings():
	# get the keybindings
	var keybindings = ConfigFileManager.load_keybindings()
	# go through each
	for action in keybindings.keys():
		# for each input, add the actions
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])
	# check what input is used for the controls
	check_button_inputs()

# loads the audio settings from the settings
func load_audio_from_settings():
	# get the audio settings
	var audio_settings = ConfigFileManager.load_audio_setting()
	# get the slider values to match the audio settings
	master_sound_slider.value = min(audio_settings.master_volume, 1.0) * 10
	music_sound_slider.value = min(audio_settings.music_volume, 1.0) * 10
	sfx_sound_slider.value = min(audio_settings.sfx_volume, 1.0) * 10

# return if the options menu is checking for input
func is_input_screen_open():
	return checking_input

# close the input screen
func input_screen_close():
	# do not check for input
	checking_input = false
	# check control inputs
	check_button_inputs()
	# hide the awaiting input screen
	awaiting_input.hide()

func input_screen_open():
	awaiting_input.show()
	checking_input = true

func _on_toggle_fullscreen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		set_window_mode_text()
		ConfigFileManager.save_window_settings("fullscreen", true)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_window_mode_text()
		ConfigFileManager.save_window_settings("fullscreen", false)

func set_window_mode_text():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		toggle_fullscreen_button.text = "Windowed"
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		toggle_fullscreen_button.text = "Fullscreen"
