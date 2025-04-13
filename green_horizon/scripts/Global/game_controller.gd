extends Node

var total_items: int = 0
var returning_from_mission: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	EventController.connect("level_lost", Callable(self, "_on_level_lost"))
	
func item_collected(value: int):
	total_items = total_items + value
	EventController.emit_signal("item_collected", total_items)
	
	if total_items == 12:
		total_items = 0
		EventController.emit_signal("level_completed")
		
func _on_level_lost():
	total_items = 0
