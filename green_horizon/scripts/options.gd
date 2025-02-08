### OPTIONS ### MENU SCRIPT

class_name OptionsMenu
extends Control

#Buttons
@onready var exit_options: TextureButton = $Margins/Vertical_Alignment/ExitOptions
@onready var click: AudioStreamPlayer = $"../Click"

#Signals
signal exit_menu

func _ready():
	exit_options.button_down.connect(on_exit_pressed)
	set_process(false)

func on_exit_pressed() -> void:
	exit_menu.emit()
	set_process(false)
	click.play()
