extends Node2D

# Others
@onready var tilemap = $TileMap
@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer

func _ready():
	animation_player.play("fade-out")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta: float):
	if Input.is_action_just_pressed("open_menu"):
		animation_player.play("fade")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade":
		get_tree().change_scene_to_file("res://scenes/MainMenu/main_menu.tscn")
