extends Node

# sets the file path
const FILE_PATH = "user://settings.ini"
var config = ConfigFile.new()

# on start
func _ready():
	# if files path does not exist
	if !FileAccess.file_exists(FILE_PATH):
		# set default keybinds
		config.set_value("keybinding", "MoveUp", "W")
		config.set_value("keybinding", "MoveDown", "S")
		config.set_value("keybinding", "MoveRight", "D")
		config.set_value("keybinding", "MoveLeft", "A")
		config.set_value("keybinding", "Attack", "mouse_1")
		config.set_value("keybinding", "Pause", "Escape")
		# set default audio settings
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		# save the file
		config.save(FILE_PATH)
	# if the file exists, load the settings file
	else:
		config.load(FILE_PATH)

# saves the audio setting that is inputted
func save_audio_setting(key : String, value):
	config.set_value("audio", key, value)
	# save the settings
	config.save(FILE_PATH)

# load the audio settings
func load_audio_setting():
	var audio_settings = {}
	# each key in the audio sections
	for key in config.get_section_keys("audio"):
		# set the volume audio_settings[key] from the setting
		audio_settings[key] = config.get_value("audio", key)
		# adjust the sound to match the audio bus settings
		## NOTE: the sliders do this as well
		var sound_change
		if audio_settings[key] != 0:
			sound_change = -3.0 * (10.0 - audio_settings[key] * 10)
		elif audio_settings[key] == 0:
			sound_change = -80.0
		# if the key is music_volume
		if key == "music_volume":
			# set the audio bus volume
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), sound_change)
		# if the key is sfx_volume
		elif key == "sfx_volume":
			# set the audio bus volume
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effect"), sound_change)
	# return the audio settings
	return audio_settings

# save the keybinding that is inputted
func save_keybindings(action: StringName, event: InputEvent):
	# save the string based on the type of InputEvent
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	# set the keybinding
	config.set_value("keybinding", action, event_str)
	# save the settings
	config.save(FILE_PATH)

# load the keybinding settings
func load_keybindings():
	var keybindings = {}
	# each keybindings in the keybindings sections
	var keys = config.get_section_keys("keybinding")
	# for each key in the keybindings
	for key in keys:
		var input_event
		# get the string for the keybinding
		var event_str = config.get_value("keybinding", key)
		# if the string has a mouse button
		if event_str.contains("mouse_"):
			# adjust the string to match the button godot uses
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		# if the string is not a mouse button
		else:
			# copy the keycode over
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		# set the input event for the key
		keybindings[key] = input_event
	# return the keybindings
	return keybindings
