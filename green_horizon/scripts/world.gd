### WORLD ### TRANSITION SCRIPT

extends Node2D

# Others
@onready var tilemap = $TileMap

# Scenes
var main_menu: PackedScene = null

func _ready():
	main_menu = load("res://scenes/main_menu.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta: float):
	if Input.is_action_just_pressed("open_menu"):
		back_to_menu()

func back_to_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)
