### MALE ### CC SCRIPT
extends Node2D

@onready var name_box: TextEdit = $CreatorScreen/CCBG/Name/TextEdit
@onready var confirm_button: TextureButton = $CreatorScreen/CCBG/ConfirmButton


@onready var Bm_sprite_2d: Sprite2D = $Skeleton/Body/M_Sprite2D
@onready var Bf_sprite_2d: Sprite2D = $Skeleton/Body/F_Sprite2D
@onready var Hm_sprite_2d: Sprite2D = $Skeleton/Hair/M_Sprite2D
@onready var Hf_sprite_2d: Sprite2D = $Skeleton/Hair/F_Sprite2D
@onready var Om_sprite_2d: Sprite2D = $Skeleton/Outfit/M_Sprite2D
@onready var Of_sprite_2d: Sprite2D = $Skeleton/Outfit/F_Sprite2D

var player_name = ""
var is_female = false

func _ready():
	is_female = Global.is_female
	update_character_visibility()

func _on_text_edit_text_changed():
	player_name = name_box.text
	confirm_button.disabled = player_name.is_empty()

func _on_confirm_button_pressed():
	if not player_name.is_empty():
		player_name = Global.player_name
		Global.is_female = is_female
		get_tree().change_scene_to_file("res://scenes/mission.tscn")

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
