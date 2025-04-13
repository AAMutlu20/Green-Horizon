extends Node2D

@onready var transition: AnimationPlayer = $CanvasLayer/Control/AnimationPlayer
@onready var player: CharacterBody2D = $Player

func _ready():
	if player:
		player.player_died.connect(_on_player_died)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	EventController.level_completed.connect(on_level_completed)

func _on_player_died():
	EventController.emit_signal("level_lost")

func _on_animation_player_animation_finished(_anim_name):
	GameController.returning_from_mission = true
	get_tree().change_scene_to_file("res://scenes/Game/main.tscn")

func on_level_completed():
	GameSaveManager.autosave()
	transition.play("transition_win")
	transition.animation_finished.connect(_on_animation_player_animation_finished)

func on_level_lost():
	GameSaveManager.autosave() 
	transition.play("transition")
	transition.animation_finished.connect(_on_animation_player_animation_finished)
