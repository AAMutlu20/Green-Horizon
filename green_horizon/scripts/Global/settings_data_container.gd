extends Node

# Variables
@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://resources/Settings/default_settings.tres")

var window_mode_index : int = 0
var resolution_index : int = 0
var master_volume : float = 0.0
var music_volume : float = 0.0
var sfx_volume : float = 0.0

var loaded_data : Dictionary = {}

func _ready():
	handle_signals()
	create_storage_dictionary()

func handle_signals() -> void:
	SettingsSignalBus.on_window_mode_selected.connect(on_on_window_mode_selected)
	SettingsSignalBus.on_resolution_selected.connect(on_on_resolution_selected)
	SettingsSignalBus.on_master_sound_set.connect(on_on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_on_sfx_sound_set)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)

# Storage dictionary
func create_storage_dictionary() -> Dictionary:
	var settings_container_dict : Dictionary = {
		"window_mode_index" : window_mode_index,
		"resolution_index" : resolution_index,
		"master_volume" : master_volume,
		"music_volume" : music_volume,
		"sfx_volume" : sfx_volume,
	}
	
	return settings_container_dict

# Get Functions

# Template for copy - paste
#func get_() -> void: 
#	if loaded_data == {}:
#		return
#	return

func get_window_mode_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.WINDOW_MODE_INDEX
	return window_mode_index

func get_resolution_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.RESOLUTION_INDEX
	return resolution_index

func get_master_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.MASTER_VOLUME
	return master_volume

func get_music_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.MUSIC_VOLUME
	return music_volume

func get_sfx_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.SFX_VOLUME
	return sfx_volume


# Set Functions
func on_on_window_mode_selected(index : int) -> void:
	window_mode_index = index

func on_on_resolution_selected(index : int) -> void:
	resolution_index = index

func on_on_master_sound_set(value : float) -> void:
	master_volume = value
	save_settings()

func on_on_music_sound_set(value : float) -> void:
	music_volume = value
	save_settings()

func on_on_sfx_sound_set(value : float) -> void:
	sfx_volume = value
	save_settings()

func save_settings() -> void:
	var settings_dict = create_storage_dictionary()
	SettingsSignalBus.emit_set_settings_dictionary(settings_dict)

# Loading data 
func on_settings_data_loaded(data : Dictionary) -> void:
	loaded_data = data
	on_on_window_mode_selected(loaded_data.window_mode_index)
	on_on_resolution_selected(loaded_data.resolution_index)
	on_on_master_sound_set(loaded_data.master_volume)
	on_on_music_sound_set(loaded_data.music_volume)
	on_on_sfx_sound_set(loaded_data.sfx_volume)
