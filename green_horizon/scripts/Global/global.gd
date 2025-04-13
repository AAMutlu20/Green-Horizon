### GLOBAL ### AUTOLOAD SCRIPT

extends Node

# MALE PLAYER
var male_bodies_collection = {
	"01" : preload("res://assets/Character/Male/Body/M1_Sheet.png"),
	"02" : preload("res://assets/Character/Male/Body/M2_Sheet.png"),
	"03" : preload("res://assets/Character/Male/Body/M3_Sheet.png")
}
var male_hairstyles_collection = {
	"none" : null,
	"01" : preload("res://assets/Character/Male/Hair/M1_Sheet.png"),
	"02" : preload("res://assets/Character/Male/Hair/M2_Sheet.png"),
	"03" : preload("res://assets/Character/Male/Hair/M3_Sheet.png"),
	"04" : preload("res://assets/Character/Male/Hair/M4_Sheet.png"),
	"05" : preload("res://assets/Character/Male/Hair/M5_Sheet.png")
}
var male_outfits_collection = {
	"01" : preload("res://assets/Character/Male/Shirt/S1_Sheet.png"),
	"02" : preload("res://assets/Character/Male/Shirt/S2_Sheet.png"),
	"03" : preload("res://assets/Character/Male/Shirt/S3_Sheet.png"),
	"04" : preload("res://assets/Character/Male/Shirt/S4_Sheet.png"),
	"05" : preload("res://assets/Character/Male/Shirt/S5_Sheet.png")
}

# FEMALE PLAYER
var female_bodies_collection = {
	"01" : preload("res://assets/Character/Female/Body/F1_Sheet.png"),
	"02" : preload("res://assets/Character/Female/Body/F2_Sheet.png"),
	"03" : preload("res://assets/Character/Female/Body/F3_Sheet.png")
}
var female_hairstyles_collection = {
	"none" : null,
	"01" : preload("res://assets/Character/Female/Hair/F1_Sheet.png"),
	"02" : preload("res://assets/Character/Female/Hair/F2_Sheet.png"),
	"03" : preload("res://assets/Character/Female/Hair/F3_Sheet.png"),
	"04" : preload("res://assets/Character/Female/Hair/F4_Sheet.png"),
	"05" : preload("res://assets/Character/Female/Hair/F5_Sheet.png")
}
var female_outfits_collection = {
	"01" : preload("res://assets/Character/Female/Outfit/F1_Sheet.png"),
	"02" : preload("res://assets/Character/Female/Outfit/F2_Sheet.png"),
	"03" : preload("res://assets/Character/Female/Outfit/F3_Sheet.png"),
	"04" : preload("res://assets/Character/Female/Outfit/F4_Sheet.png"),
	"05" : preload("res://assets/Character/Female/Outfit/F5_Sheet.png")
}

# SELECTED VALUES
var selected_body = ""
var selected_hair = ""
var selected_outfit = ""
var is_female = false
