extends Control

signal build_refinery
signal build_water
signal build_hill
signal build_mountain
signal build_solar
signal build_city

@onready var mission_forest: PackedScene = preload("res://scenes/Mission/character_creator.tscn")
@onready var mission_button: Button = $TextureRect/Tasks/Forest/Button

@onready var refinery_button: Button = $TextureRect/Tasks/Refinery/Button
@onready var water_button: Button = $TextureRect/Tasks/WaterPlant/Button
@onready var hill_button: Button = $TextureRect/Tasks/HillMine/Button
@onready var mountain_button: Button = $TextureRect/Tasks/MountainMine/Button
@onready var solar_button: Button = $TextureRect/Tasks/SolarPanel/Button
@onready var city_button: Button = $TextureRect/Tasks/City/Button


var turn_count = 0
var mission_available = false

func _ready():
	mission_button.disabled = true
	get_tree().get_nodes_in_group("world_controller")[0].connect("new_turn", Callable(self, "_on_new_turn"))
	mission_button.connect("pressed", Callable(self, "on_button_pressed"))
	
	refinery_button.connect("pressed", Callable(self, "on_refinery_pressed"))
	water_button.connect("pressed", Callable(self, "on_water_pressed"))
	hill_button.connect("pressed", Callable(self, "on_hill_pressed"))
	mountain_button.connect("pressed", Callable(self, "on_mountain_pressed"))
	solar_button.connect("pressed", Callable(self, "on_solar_pressed"))
	city_button.connect("pressed", Callable(self, "on_city_pressed"))

func _on_new_turn():
	turn_count += 1
	if turn_count >= 5:
		mission_button.disabled = false
		mission_available = true
		turn_count = 0

func on_button_pressed():
	if mission_available:
		mission_available = false
		mission_button.disabled = true
		turn_count = 0
		get_tree().change_scene_to_packed(mission_forest)

func on_refinery_pressed() -> void:
	emit_signal("build_refinery")
	print("boop.")

func on_water_pressed() -> void:
	emit_signal("build_water")
	print("boop.")

func on_hill_pressed() -> void:
	emit_signal("build_hill")
	print("boop.")

func on_mountain_pressed() -> void:
	emit_signal("build_mountain")
	print("boop.")

func on_solar_pressed() -> void:
	emit_signal("build_solar")
	print("boop.")

func on_city_pressed() -> void:
	emit_signal("build_city")
	print("boop.")
