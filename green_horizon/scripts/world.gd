extends Node2D

@onready var tilemap = $TileMap

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta: float):
	Escape()

func Escape():
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()
