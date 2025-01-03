class_name KeybindRebindButton
extends Control

#Buttons
@onready var button: Button = $HBoxContainer/Button

#Others
@onready var label: Label = $HBoxContainer/Label
@onready var confirm: AudioStreamPlayer = $Confirm

#Exports
@export var action_name: String = "cam_move_up"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()

func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		#Camera
		"cam_move_up":
			label.text = "Camera Move Up"
		"cam_move_down":
			label.text = "Camera Move Down"
		"cam_move_left":
			label.text = "Camera Move Left"
		"cam_move_right":
			label.text = "Camera Move Right"
		#Player
		"p_move_up":
			label.text = "Player Move Up"
		"p_move_down":
			label.text = "Player Move Down"
		"p_move_left":
			label.text = "Player Move Left"
		"p_move_right":
			label.text = "Player Move Right"
		"p_interact":
			label.text = "Player Interact"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	
		button.text = "%s" % action_keycode
	else:
		button.text = "Unassigned"

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		button.text =  "Press any key..."
		set_process_unhandled_key_input(toggled_on)
		
		for i in get_tree().get_nodes_in_group("keybind_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
				confirm.play()
	else:
		for i in get_tree().get_nodes_in_group("keybind_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
				confirm.play()
		set_text_for_key()

func _unhandled_key_input(event: InputEvent) -> void:
	rebind_action_key(event)
	button.button_pressed = false

func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
