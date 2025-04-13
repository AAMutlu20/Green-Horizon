extends Control

@onready var value_label: Label = $HBoxContainer/Value

func _ready():
	EventController.connect("item_collected", on_event_item_collected)

func on_event_item_collected(value: int) -> void:
	value_label.text = str(value)
