extends TileMapLayer

# Pollution States
const POLLUTION_CLEAN = 0
const POLLUTION_MILD = 1
const POLLUTION_POLLUTED = 2
const POLLUTION_UNINHABITABLE = 3


# Other Constants
const MAX_POLLUTION = 100
var total_tiles = 0
var isTurn = true
var isNight = false
var last_pollution_spread_time = -1

# Dictionary
var pollution_levels = {}

# Tile Thresholds
var pollution_thresholds = {
	2: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 20, POLLUTION_UNINHABITABLE: 50},  # C_WATER
	19: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 10, POLLUTION_POLLUTED: 20, POLLUTION_UNINHABITABLE: 50},  # C_RIVER
	5: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 60},  # C_FIELD
	23: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 60},  # C_DESERT
	9: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 17},  # C_FOREST_C
	11: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 18, POLLUTION_POLLUTED: 28, POLLUTION_UNINHABITABLE: 58},  # C_FOREST
	15: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 22, POLLUTION_POLLUTED: 32, POLLUTION_UNINHABITABLE: 62},  # C_HILL
	35: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 30, POLLUTION_POLLUTED: 45, POLLUTION_UNINHABITABLE: 68},  # C_MOUNTAIN
	27: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 60},  # C_SANDS
	31: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 22, POLLUTION_POLLUTED: 32, POLLUTION_UNINHABITABLE: 62},  # C_D_HILL
	40: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25},  # C_REFINERY
}

@onready var pollution_bar: TextureProgressBar = $"../../UI/TextureRect/HBoxContainer/PollutionBar"
@onready var display_state: Label = $"../../UI/TextureRect/HBoxContainer/DisplayState"
@onready var turn: Button = $"../../UI/TextureRect/HBoxContainer2/Turn"

func initialize_pollution():
	var left = -345
	var right = 285
	var top = -270
	var bot = 330
	total_tiles = 0
	for x in range(left, right):
		for y in range(top, bot):
			var tile_pos = Vector2i(x, y)
			var tile_id = get_cell_source_id(tile_pos)
			if tile_id != -1:
				var pollution = randi_range(0, 20)
				pollution_levels[tile_pos] = pollution
				var thresholds = pollution_thresholds.get(tile_id, {})
				var state = determine_pollution_state(pollution, thresholds)
				set_tile_state(tile_pos, tile_id, state, pollution)
				total_tiles += 1
	update_pollution_ui()

func update_pollution(tile_pos: Vector2i, pollution_delta: int):
	if pollution_levels.has(tile_pos):
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id != -1:
			var thresholds = pollution_thresholds.get(tile_id, {})
			pollution_levels[tile_pos] = clamp(pollution_levels[tile_pos] + pollution_delta, 0, 100)
			var new_pollution_level = pollution_levels[tile_pos]
			var state = determine_pollution_state(new_pollution_level, thresholds)
			set_tile_state(tile_pos, tile_id, state, new_pollution_level)
			update_pollution_ui()

func determine_pollution_state(pollution_level: int, thresholds: Dictionary) -> int:
	var state = POLLUTION_CLEAN
	for level in thresholds.keys():
		if pollution_level >= thresholds[level]:
			state = level
	return state

func set_tile_state(tile_pos: Vector2i, tile_id: int, state: int, pollution_level: int):
	match tile_id:
		2:  # C_WATER
			if pollution_level > 50:
				set_cell(tile_pos, 4, Vector2i(0, 0))  # Polluted
			elif pollution_level > 20:
				set_cell(tile_pos, 3, Vector2i(0, 0))  # Mild
			else:
				set_cell(tile_pos, 2, Vector2i(0, 0))  # Clean
		9:  # C_FOREST_C
			if pollution_level > 17:
				set_cell(tile_pos, 10, Vector2i(0, 0))  # Polluted
			else:
				set_cell(tile_pos, 9, Vector2i(0, 0))  # Clean
		40:  # C_REFINERY
			if pollution_level > 25:
				set_cell(tile_pos, 42, Vector2i(0, 0)) # Polluted
			elif pollution_level > 15:
				set_cell(tile_pos, 41, Vector2i(0, 0)) # Mild
			else:
				set_cell(tile_pos, 40, Vector2i(0, 0)) # Clean
		_:
			if state == POLLUTION_CLEAN:
				set_cell(tile_pos, tile_id, Vector2i(0, 0))  # CLean
			elif state == POLLUTION_MILD:
				set_cell(tile_pos, tile_id + 1, Vector2i(0, 0))  # Mild
			elif state == POLLUTION_POLLUTED:
				set_cell(tile_pos, tile_id + 2, Vector2i(0, 0))  # Polluted
			elif state == POLLUTION_UNINHABITABLE:
				set_cell(tile_pos, tile_id + 3, Vector2i(0, 0))  # Uninhabitable

func update_hover_label():
	var mouse_pos = get_global_mouse_position()
	var tile_pos = local_to_map(mouse_pos)
	var tile_id = get_cell_source_id(tile_pos)
	if tile_id != -1 and pollution_levels.has(tile_pos):
		var pollution_level = pollution_levels[tile_pos]
		display_state.text = "Tile ID: %d\nPollution Level: %d" % [tile_id, pollution_level]
		display_state.visible = true
	else:
		display_state.visible = false

func calculate_total_pollution() -> int:
	var total_pollution = 0
	for pollution in pollution_levels.values():
		total_pollution += pollution
	return total_pollution

func update_pollution_ui():
	if pollution_bar:
		var total_pollution = calculate_total_pollution()
		var max_possible_pollution = total_tiles * MAX_POLLUTION
		var pollution_percentage = float(total_pollution) / max_possible_pollution * 100
		pollution_bar.value = pollution_percentage

func handle_turn():
	if isTurn:
		print("It's your turn! You can take actions.")
	else:
		print("It's Night, pollution may spread.")

func spread_pollution():
	if !isNight: return

	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		var pollution = pollution_levels[tile_pos]
		var thresholds = pollution_thresholds.get(tile_id, {})
		var state = determine_pollution_state(pollution, thresholds)
		
		if state == POLLUTION_CLEAN:
			pass
		elif state == POLLUTION_MILD:
			if tile_id == 19:  # M_RIVER
				spread_pollution_to_neighbors(tile_pos, 1.25)
			elif tile_id == 2:  # M_WATER
				spread_pollution_to_neighbors(tile_pos, 1.25)
			elif tile_id == 11:  # M_FOREST
				spread_pollution_to_neighbors(tile_pos, 1.5)
			elif tile_id == 5:  # M_FIELD
				spread_pollution_to_neighbors(tile_pos, 1.1)
			elif tile_id == 23:  # M_DESERT
				spread_pollution_to_neighbors(tile_pos, 1.4)
			elif tile_id == 40:  # M_REFINERY
				spread_pollution_to_neighbors(tile_pos, 1.9)
			elif tile_id == 15:  # M_HILL
				spread_pollution_to_neighbors(tile_pos, 1.35)
			elif tile_id == 35:  # M_MOUNTAIN
				spread_pollution_to_neighbors(tile_pos, 1.5)
			elif tile_id == 27:  # M_SANDS
				spread_pollution_to_neighbors(tile_pos, 1.4)
			elif tile_id == 31:  # M_D_HILL
				spread_pollution_to_neighbors(tile_pos, 1.45)
		elif state == POLLUTION_POLLUTED:
			if tile_id == 19:  # P_RIVER
				spread_pollution_to_neighbors(tile_pos, 2)
			elif tile_id == 2:  # P_WATER
				spread_pollution_to_neighbors(tile_pos, 2.25)
			elif tile_id == 11:  # P_FOREST
				spread_pollution_to_neighbors(tile_pos, 2.2)
			elif tile_id == 5:  # P_FIELD
				spread_pollution_to_neighbors(tile_pos, 1.4)
			elif tile_id == 23:  # P_DESERT
				spread_pollution_to_neighbors(tile_pos, 1.4)
			elif tile_id == 40:  # P_REFINERY
				spread_pollution_to_neighbors(tile_pos, 1.3)
			elif tile_id == 15:  # P_HILL
				spread_pollution_to_neighbors(tile_pos, 1.6)
			elif tile_id == 35:  # P_MOUNTAIN
				spread_pollution_to_neighbors(tile_pos, 1.75)
			elif tile_id == 27:  # P_SANDS
				spread_pollution_to_neighbors(tile_pos, 1.6)
			elif tile_id == 31:  # P_D_HILL
				spread_pollution_to_neighbors(tile_pos, 1.65)
		elif state == POLLUTION_UNINHABITABLE:
			if tile_id == 19:  # U_RIVER
				spread_pollution_to_neighbors(tile_pos, 2.5)
			elif tile_id == 2:  # U_WATER
				spread_pollution_to_neighbors(tile_pos, 2.5)
			elif tile_id == 11:  # U_FOREST
				spread_pollution_to_neighbors(tile_pos, 2.5)
			elif tile_id == 5:  # U_FIELD
				spread_pollution_to_neighbors(tile_pos, 1.5)
			elif tile_id == 23:  # U_DESERT
				spread_pollution_to_neighbors(tile_pos, 1.5)
			elif tile_id == 40:  # U_REFINERY
				spread_pollution_to_neighbors(tile_pos, 1.4)
			elif tile_id == 15:  # U_HILL
				spread_pollution_to_neighbors(tile_pos, 1.8)
			elif tile_id == 35:  # U_MOUNTAIN
				spread_pollution_to_neighbors(tile_pos, 2)
			elif tile_id == 27:  # U_SANDS
				spread_pollution_to_neighbors(tile_pos, 1.8)
			elif tile_id == 31:  # U_D_HILL
				spread_pollution_to_neighbors(tile_pos, 1.85)

func spread_pollution_to_neighbors(tile_pos: Vector2i, rate: float):
	var neighbors = get_neighbors(tile_pos)
	for neighbor in neighbors:
		update_pollution(neighbor, rate)

func passive_pollution(tile_pos: Vector2i, rate: float):
	update_pollution(tile_pos, rate)

func get_neighbors(tile_pos: Vector2i) -> Array:
	var neighbors = []
	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]
	for dir in directions:
		var neighbor_pos = tile_pos + dir
		neighbors.append(neighbor_pos)
	return neighbors

func next_turn():
	isTurn = !isTurn
	isNight = !isNight  
	if isNight:
		spread_pollution()
	update_turn_ui()

func update_turn_ui():
	if isTurn:
		display_state.text = "It's your turn (Day)."
	else:
		display_state.text = "It's not your turn (Night)."

func _on_turn_button_toggled():
	next_turn()

func _ready():
	print(pollution_bar)
	initialize_pollution()
	handle_turn()
	turn.connect("pressed", Callable(self, "_on_turn_button_toggled"))

func _process(delta):
	if isTurn:
		update_hover_label()
