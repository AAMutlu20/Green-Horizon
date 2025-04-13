### CHARACTER CREATOR ### SCRIPT
extends Node2D

@onready var confirm_button: TextureButton = $CreatorScreen/CCBG/ConfirmButton

@onready var Bm_sprite_2d: Sprite2D = $CreatorScreen/Control/Skeleton/Body/M_Sprite2D
@onready var Bf_sprite_2d: Sprite2D = $CreatorScreen/Control/Skeleton/Body/F_Sprite2D

@onready var Hm_sprite_2d: Sprite2D = $CreatorScreen/Control/Skeleton/Hair/M_Sprite2D
@onready var Hf_sprite_2d: Sprite2D = $CreatorScreen/Control/Skeleton/Hair/F_Sprite2D

@onready var Om_sprite_2d: Sprite2D = $CreatorScreen/Control/Skeleton/Outfit/M_Sprite2D
@onready var Of_sprite_2d: Sprite2D = $CreatorScreen/Control/Skeleton/Outfit/F_Sprite2D

var is_female = false

func _ready():
	is_female = Global.is_female
	update_character_visibility()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_confirm_button_pressed():
		Global.is_female = is_female
		get_tree().change_scene_to_file("res://scenes/Mission/mission.tscn")

func update_character_visibility():
	Bm_sprite_2d.visible = not is_female
	Bf_sprite_2d.visible = is_female
	Hm_sprite_2d.visible = not is_female
	Hf_sprite_2d.visible = is_female
	Om_sprite_2d.visible = not is_female
	Of_sprite_2d.visible = is_female


func _on_check_button_toggled(toggled_on: bool):
	is_female = toggled_on
	update_character_visibility()
