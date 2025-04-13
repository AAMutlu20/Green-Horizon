### WINDOW SCREEN ### MENU SCRIPT

extends Control

# Buttons
@onready var option_button: OptionButton = $HBoxContainer/OptionButton

# Sounds
@onready var confirm: AudioStreamPlayer = $Confirm

# Constants
const WINDOW_MODE_ARRAY: Array[String] = [
	"Window Mode",
	"Borderless Mode",
]

func _ready():
	add_window_mode_items()
	option_button.item_selected.connect(on_window_mode_selected)
	load_data()

func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		option_button.add_item(window_mode)

func load_data() -> void:
	on_window_mode_selected(DataSignalBus.get_window_mode_index())
	option_button.select(DataSignalBus.get_window_mode_index())

func on_window_mode_selected(index : int) -> void:
	SettingsSignalBus.emit_on_window_mode_selected(index)
	match index:
		0: # Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			confirm.play()
		1: # Borderless Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			confirm.play()
