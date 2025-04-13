### MALE BODY ### CC SCRIPT

extends Node2D

@onready var body_sprite: Sprite2D = $M_Sprite2D
@onready var f_sprite_2d: Sprite2D = $F_Sprite2D

var male_body_keys = []
var female_body_keys = []
var current_male_body_index = 0
var current_female_body_index = 0

var is_female = false

func _ready():
	set_male_sprite_keys()
	set_female_sprite_keys()
	update_sprite()

func set_male_sprite_keys():
	male_body_keys = Global.male_bodies_collection.keys()

func set_female_sprite_keys():
	female_body_keys = Global.female_bodies_collection.keys()

func update_sprite():
	if is_female:
		var current_sprite = female_body_keys[current_female_body_index]
		f_sprite_2d.texture = Global.female_bodies_collection[current_sprite]
		Global.selected_body = current_sprite
	else:
		var current_sprite = male_body_keys[current_male_body_index]
		body_sprite.texture = Global.male_bodies_collection[current_sprite]
		Global.selected_body = current_sprite

func _on_collection_button_pressed():
	if is_female:
		current_female_body_index = (current_female_body_index + 1) % female_body_keys.size()
	else:
		current_male_body_index = (current_male_body_index + 1) % male_body_keys.size()
	update_sprite()

func _on_check_button_toggled(toggled_on: bool) -> void:
	is_female = toggled_on

	body_sprite.visible = not is_female
	f_sprite_2d.visible = is_female

	if is_female:
		current_female_body_index = 0
	else:
		current_male_body_index = 0
	update_sprite()
