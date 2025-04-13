extends Control

# Scene Elements
@onready var body: TextureRect = $Body
@onready var icon: TextureRect = $Icon

# Image Paths
# Mission
const MISSION_POPUP = preload("res://assets/GUI/Popup/MissionPopup.png")
const MISSION_POPUP_LOCKED = preload("res://assets/GUI/Popup/MissionPopupLocked.png")
# Icon
const FOREST_PLAINS = preload("res://assets/GUI/Popup/Cards/Forest&Plains.png")
const MINE = preload("res://assets/GUI/Popup/Cards/Mine.png")
const D_MINE = preload("res://assets/GUI/Popup/Cards/D_Mine.png")

var tile_id: int

func set_tile_id(id: int):
	tile_id = id
	_update_popup()

func _update_popup():
	if tile_id in [9, 10, 14, 58, 59, 76, 77]:
		# Set locked popup
		body.texture = MISSION_POPUP_LOCKED
	elif tile_id in [11, 12, 13, 52, 53, 54, 55, 56, 57, 72, 73, 74, 75]:
		# Set unlocked popup
		body.texture = MISSION_POPUP

	if tile_id in [9, 10, 11, 12, 13, 14]:
		icon.texture = FOREST_PLAINS
	elif tile_id in [52, 53, 54, 55, 56, 57, 58, 59]:
		icon.texture = MINE
	elif tile_id in [72, 73, 74, 75, 76, 77]:
		icon.texture = D_MINE
