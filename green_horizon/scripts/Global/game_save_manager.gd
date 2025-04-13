extends Node

signal save_completed()
signal load_completed()

const SAVE_DIR = "user://saves/"
const SAVE_FILE_EXTENSION = ".save"

var current_slot: String = "slot_1"
var autosave_enabled: bool = true
var autosave_frequency: int = 1
var turn_counter: int = 0

func _ready():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)
	
	call_deferred("connect_to_world_controller")

func connect_to_world_controller():
	var world_controller = get_world_controller()
	if world_controller:
		connect_to_turn_signal(world_controller)
	else:
		print("WARNING: World controller not found on ready, will try again later")
		await get_tree().create_timer(0.5).timeout
		connect_to_world_controller()

func connect_to_turn_signal(world_controller):
	if not world_controller.is_connected("new_turn", Callable(self, "_on_turn_completed")):
		world_controller.connect("new_turn", Callable(self, "_on_turn_completed"))
		print("Connected to world controller's new_turn signal")

func _on_turn_completed():
	turn_counter += 1
	if autosave_enabled and turn_counter % autosave_frequency == 0:
		autosave()

func autosave():
	save_game("autosave")
	print("Game autosaved")

func save_game(slot_name: String = "") -> bool:
	if slot_name.is_empty():
		slot_name = current_slot
	else:
		current_slot = slot_name
	
	var world_controller = get_world_controller()
	if not world_controller:
		print("Error: World controller not found")
		return false
	
	var save_data = {
		"timestamp": Time.get_datetime_dict_from_system(),
		"version": ProjectSettings.get_setting("application/config/version", "1.0.0"),
		"turn_counter": turn_counter,
		"is_turn": world_controller.isTurn,
		"is_night": world_controller.isNight,
		"turns_till_growth": world_controller.turns_till_growth,
		"pollution_levels": world_controller.pollution_levels,
		"tile_resources": world_controller.tile_resources_at_position,
		"main_stockpile": world_controller.main_stockpile,
		"total_tiles": world_controller.total_tiles
	}
	
	var file_path = SAVE_DIR + slot_name + SAVE_FILE_EXTENSION
	var error = _write_save_data(file_path, save_data)
	
	if error == OK:
		emit_signal("save_completed")
		return true
	else:
		print("Error saving game: " + str(error))
		return false

func load_game(slot_name: String = "") -> bool:
	if slot_name.is_empty():
		slot_name = current_slot
	else:
		current_slot = slot_name
	
	var file_path = SAVE_DIR + slot_name + SAVE_FILE_EXTENSION
	var save_data = _read_save_data(file_path)
	
	if save_data.is_empty():
		print("Error: Could not load save data")
		return false
	
	var world_controller = get_world_controller()
	if not world_controller:
		print("Error: World controller not found")
		return false
	
	world_controller.isTurn = save_data.is_turn
	world_controller.isNight = save_data.is_night
	world_controller.turns_till_growth = save_data.turns_till_growth
	world_controller.pollution_levels = save_data.pollution_levels
	world_controller.tile_resources_at_position = save_data.tile_resources
	world_controller.main_stockpile = save_data.main_stockpile
	world_controller.total_tiles = save_data.total_tiles
	turn_counter = save_data.turn_counter
	
	world_controller.update_resource_ui()
	world_controller.update_pollution_ui()
	world_controller.update_turn_ui()
	
	for tile_pos in world_controller.pollution_levels.keys():
		var tile_id = world_controller.get_cell_source_id(tile_pos)
		if tile_id > 0:
			var pollution = world_controller.pollution_levels[tile_pos]
			var state = world_controller.determine_pollution_state(pollution)
			world_controller.set_tile_state(tile_pos, tile_id, state, pollution)
	
	emit_signal("load_completed")
	return true

func get_world_controller():

	var root = get_tree().get_root()
	
	var controllers = get_tree().get_nodes_in_group("world_controller")
	if controllers.size() > 0:
		return controllers[0]
	
	var main_scene = root.get_child(root.get_child_count() - 1)
	if main_scene.has_node("TileMap/Layer1"):
		return main_scene.get_node("TileMap/Layer1")
	
	return _find_world_controller_recursive(main_scene)

func _find_world_controller_recursive(node):
	if node.get_script() and node.get_script().resource_path.find("world_controller") >= 0:
		return node
	
	for child in node.get_children():
		var result = _find_world_controller_recursive(child)
		if result:
			return result
	
	return null

func _write_save_data(file_path: String, save_data: Dictionary) -> int:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var serializable_data = save_data.duplicate()
		
		var pollution_dict = {}
		for key in serializable_data.pollution_levels.keys():
			var key_str = str(key.x) + "," + str(key.y)
			pollution_dict[key_str] = serializable_data.pollution_levels[key]
		serializable_data.pollution_levels = pollution_dict
		
		var resources_dict = {}
		for key in serializable_data.tile_resources.keys():
			var key_str = str(key.x) + "," + str(key.y)
			resources_dict[key_str] = serializable_data.tile_resources[key]
		serializable_data.tile_resources = resources_dict
		
		# Convert to JSON and save
		var json_string = JSON.stringify(serializable_data)
		file.store_string(json_string)
		file.close()
		return OK
	else:
		return ERR_CANT_OPEN
		
func _read_save_data(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		print("Save file does not exist: " + file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Could not open save file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error parsing save file JSON: " + json.get_error_message())
		return {}
	
	var save_data = json.get_data()
	
	var pollution_dict = {}
	for key_str in save_data.pollution_levels.keys():
		var coords = key_str.split(",")
		var vec = Vector2i(int(coords[0]), int(coords[1]))
		pollution_dict[vec] = save_data.pollution_levels[key_str]
	save_data.pollution_levels = pollution_dict
	
	var resources_dict = {}
	for key_str in save_data.tile_resources.keys():
		var coords = key_str.split(",")
		var vec = Vector2i(int(coords[0]), int(coords[1]))
		resources_dict[vec] = save_data.tile_resources[key_str]
	save_data.tile_resources = resources_dict
	
	if save_data.has("main_stockpile"):
		var fixed_stockpile = {}
		for key_str in save_data.main_stockpile.keys():
			fixed_stockpile[int(key_str)] = save_data.main_stockpile[key_str]
		save_data.main_stockpile = fixed_stockpile
	
	return save_data

func get_save_slots() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(SAVE_FILE_EXTENSION):
				var slot_name = file_name.replace(SAVE_FILE_EXTENSION, "")
				saves.append(slot_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	return saves

func get_save_info(slot_name: String) -> Dictionary:
	var file_path = SAVE_DIR + slot_name + SAVE_FILE_EXTENSION
	var save_data = _read_save_data(file_path)
	
	if save_data.is_empty():
		return {}
		
	return {
		"slot": slot_name,
		"timestamp": save_data.timestamp,
		"version": save_data.version,
		"turn_counter": save_data.turn_counter
	}

func delete_save(slot_name: String) -> bool:
	var file_path = SAVE_DIR + slot_name + SAVE_FILE_EXTENSION
	var dir = DirAccess.open(SAVE_DIR)
	if dir.file_exists(file_path):
		var error = dir.remove(file_path)
		return error == OK
	return false
