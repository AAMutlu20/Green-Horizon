extends Control

#Buttons
@onready var option_button: OptionButton = $HBoxContainer/OptionButton

#Constants
const RESOLUTION_DICTIONARY: Dictionary = {
	"1152 x 648": Vector2i(1152, 648),
	"1280 x 720": Vector2i(1280, 720),
	"1920 x 1080": Vector2i(1920, 1080),
	"2560 x 1140": Vector2i(2560, 1140)
}

func _ready():
	option_button.item_selected.connect(on_resolution_selected)
	add_resolution_items()

func add_resolution_items() -> void:
	for resolutiion_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolutiion_size_text)


func on_resolution_selected(index : int) -> void:
	match index:
		0: #1152 x 648
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
		1: #1280 x 720
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
		2: #1920 x 1080
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
		3: #2560 x 1140
			DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])