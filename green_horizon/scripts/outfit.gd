### MALE OUTFIT ### CC SCRIPT

extends Node2D

@onready var outfit_sprite: Sprite2D = $M_Sprite2D
@onready var f_sprite_2d: Sprite2D = $F_Sprite2D


var male_outfit_keys = []
var female_outfit_keys = []
var current_male_outfit_index = 0
var current_female_outfit_index = 0

var is_female = false

func _ready():
	set_male_sprite_keys()
	set_female_sprite_keys()
	update_sprite()

func set_male_sprite_keys(): 
	male_outfit_keys = Global.male_outfits_collection.keys()

func set_female_sprite_keys():
	female_outfit_keys = Global.female_outfits_collection.keys()

func update_sprite():
	if is_female:
		var current_sprite = female_outfit_keys[current_female_outfit_index]
		f_sprite_2d.texture = Global.female_outfits_collection[current_sprite]
		Global.selected_outfit = current_sprite
	else:
		var current_sprite = male_outfit_keys[current_male_outfit_index]
		outfit_sprite.texture = Global.male_outfits_collection[current_sprite]
		Global.selected_outfit = current_sprite

func _on_collection_button_pressed():
	if is_female:
		current_female_outfit_index = (current_female_outfit_index + 1) % female_outfit_keys.size()
	else:
		current_male_outfit_index = (current_male_outfit_index + 1) % male_outfit_keys.size()
	update_sprite()

func _on_check_button_toggled(toggled_on: bool) -> void:
	is_female = toggled_on
	outfit_sprite.visible = not is_female
	f_sprite_2d.visible = is_female

	if is_female:
		current_female_outfit_index = 0
	else:
		current_male_outfit_index = 0
	update_sprite()
