class_name MainMenu
extends Control

#Buttons
@onready var play: TextureButton = $Margins/Horizontal_Alignment/Vertical_Separation/Play
@onready var options: TextureButton = $Margins/Horizontal_Alignment/Vertical_Separation/Options
@onready var exit: TextureButton = $Margins/Horizontal_Alignment/Vertical_Separation/Exit

#Others
@onready var margins: MarginContainer = $Margins

#Scenes
@onready var options_menu: OptionsMenu = $Options_Menu

#Levels
@onready var start_level: PackedScene = preload("res://scenes/main.tscn")

func _ready():
	play.button_down.connect(on_play_down)
	exit.button_down.connect(on_exit_down)
	options.button_down.connect(on_options_down)
	options_menu.exit_menu.connect(on_exit_options_menu)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func on_play_down() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_options_down() -> void:
	margins.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func on_exit_down() -> void:
	get_tree().quit()

func on_exit_options_menu() -> void:
	margins.visible = true
	options_menu.visible = false

func Escape():
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()

func _process(delta: float):
	Escape()
