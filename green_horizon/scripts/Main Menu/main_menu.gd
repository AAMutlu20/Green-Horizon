### MAIN MENU ### NORMAL SCRIPT

class_name MainMenu
extends Control

#Buttons
@onready var play: TextureButton = $Margins/Horizontal_Alignment/Vertical_Separation/Play
@onready var options: TextureButton = $Margins/Horizontal_Alignment/Vertical_Separation/Options
@onready var exit: TextureButton = $Margins/Horizontal_Alignment/Vertical_Separation/Exit

#Others
@onready var margins: MarginContainer = $Margins
@onready var click: AudioStreamPlayer = $Click

#Transitions
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#Scenes
@onready var options_menu: OptionsMenu = $Options_Menu

#Levels
@onready var start_level: PackedScene = preload("res://scenes/Game/main.tscn")

func _ready():
	play.button_down.connect(on_play_down)
	exit.button_down.connect(on_exit_down)
	options.button_down.connect(on_options_down)
	options_menu.exit_menu.connect(on_exit_options_menu)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func on_play_down() -> void:
	animation_player.play("fade-in")
	click.play()
	
func on_options_down() -> void:
	margins.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	click.play()

func on_exit_down() -> void:
	get_tree().quit()
	click.play()

func on_exit_options_menu() -> void:
	margins.visible = true
	options_menu.visible = false
	click.play()


func _on_animation_player_animation_finished(_anim_name):
	get_tree().change_scene_to_packed(start_level)
