extends Button

@onready var notebook_panel: Control = $"../../../NotebookPanel"

func _on_pressed() -> void:
	if notebook_panel.visible == true:
		notebook_panel.visible = false
	else:
		notebook_panel.visible = true
