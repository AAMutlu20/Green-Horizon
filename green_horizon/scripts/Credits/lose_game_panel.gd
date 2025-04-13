extends Panel

@onready var lose_title: Label = $lose_title
@onready var lose_message: Label = $lose_message
@onready var continue_button: TextureButton = $ContinueButton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	continue_button.connect("pressed", Callable(self, "_on_continue_button_pressed"))

func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu/main_menu.tscn")
