extends Node

const FILE_PATH = "user://settings.ini"
var config = ConfigFile.new()

func _ready():
	if !FileAccess.file_exists(FILE_PATH):
		config.set_value("keybinding", "MoveUp", "W")
		config.set_value("keybinding", "MoveDown", "S")
		config.set_value("keybinding", "MoveRight", "D")
		config.set_value("keybinding", "MoveLeft", "A")
		config.set_value("keybinding", "Attack", "mouse_1")
		config.set_value("keybinding", "Pause", "Escape")
		
		config.set_value("audio", "master_volume", .5)
		config.set_value("audio", "music_volume", .5)
		config.set_value("audio", "sfx_volume", .5)
		
		config.save(FILE_PATH)
	else:
		config.load(FILE_PATH)

func save_audio_setting(key : String, value):
	config.set_value("audio", key, value)
	config.save(FILE_PATH)

func load_audio_setting():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	
	return audio_settings

func save_keybindings(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", action, event_str)
	config.save(FILE_PATH)

func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
	return keybindings
