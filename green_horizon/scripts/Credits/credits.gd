extends Control

@onready var credits_container = $ScrollContainer/CreditsContainer
@onready var back_button: Button = $Button
@onready var music: AudioStreamPlayer = $Music
@onready var scroll_container: ScrollContainer = $ScrollContainer

var scroll_speed = 50.0
var max_scroll_value = 0
var current_scroll = 0
var scrolling_active = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	await get_tree().process_frame
	scroll_container.get_h_scroll_bar().modulate.a = 0
	scroll_container.get_v_scroll_bar().modulate.a = 0
	
	back_button.visible = false
	
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	
	music.play()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	max_scroll_value = max(0, credits_container.size.y - scroll_container.size.y)
	
	current_scroll = 0
	scroll_container.scroll_vertical = current_scroll

func _process(delta):
	if current_scroll < max_scroll_value:
		current_scroll += scroll_speed * delta
		scroll_container.scroll_vertical = min(current_scroll, max_scroll_value)
	else:
		scrolling_active = false
		await get_tree().create_timer(30.0).timeout
		_on_back_button_pressed()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu/main_menu.tscn")
