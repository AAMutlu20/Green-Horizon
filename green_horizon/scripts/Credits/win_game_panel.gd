extends Panel

@onready var win_title: Label = $win_title
@onready var win_message: Label = $win_message
@onready var continue_button: TextureButton = $TextureButton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	continue_button.connect("pressed", Callable(self, "_on_texture_button_pressed"))

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credits/credits.tscn")
