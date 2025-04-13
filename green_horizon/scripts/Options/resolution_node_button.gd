### RESOLUTION CONTROLLER ### MENU SCRIPT

extends Control

# Buttons
@onready var option_button: OptionButton = $HBoxContainer/OptionButton

# Sounds
@onready var confirm: AudioStreamPlayer = $Confirm

# Constants
const RESOLUTION_DICTIONARY: Dictionary = {
	"1152 x 648": Vector2i(1152, 648),
	"1280 x 720": Vector2i(1280, 720),
	"1920 x 1080": Vector2i(1920, 1080),
	"2560 x 1140": Vector2i(2560, 1140)
}

func _ready():
	option_button.item_selected.connect(on_resolution_selected)
	add_resolution_items()
	load_data()

func add_resolution_items() -> void:
	for resolutiion_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolutiion_size_text)

func load_data() -> void:
	on_resolution_selected(DataSignalBus.get_resolution_index())
	option_button.select(DataSignalBus.get_resolution_index())

func on_resolution_selected(index : int) -> void:
	SettingsSignalBus.emit_on_resolution_selected(index)
	match index:
		0: # 1152 x 648
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
			confirm.play()
		1: # 1280 x 720
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
			confirm.play()
		2: # 1920 x 1080
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
			confirm.play()
		3: # 2560 x 1140
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
			confirm.play()
