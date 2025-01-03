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
var turns_till_growth = 0

# Dictionary
var pollution_levels = {}

# Tile Thresholds
var pollution_thresholds = {
	2: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 20, POLLUTION_UNINHABITABLE: 50},  # C_WATER
	5: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 60},  # C_FIELD
	9: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 17},  # C_FOREST_C
	11: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 18, POLLUTION_POLLUTED: 28, POLLUTION_UNINHABITABLE: 58},  # C_FOREST
	15: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 22, POLLUTION_POLLUTED: 32, POLLUTION_UNINHABITABLE: 62},  # C_HILL
	19: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 10, POLLUTION_POLLUTED: 20, POLLUTION_UNINHABITABLE: 50},  # C_RIVER
	23: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 60},  # C_DESERT
	27: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 60},  # C_SANDS
	31: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 22, POLLUTION_POLLUTED: 32, POLLUTION_UNINHABITABLE: 62},  # C_D_HILL
	35: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 30, POLLUTION_POLLUTED: 45, POLLUTION_UNINHABITABLE: 68},  # C_MOUNTAIN
	39: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 25, POLLUTION_POLLUTED: 45},  # C_REFINERY
	42: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 35} # C_CITY
}

# Others
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
			if tile_id > 0:
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
		if tile_id > 0:
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

func set_tile_state(tile_pos: Vector2i, tile_id: int, _state: int, pollution_level: int):
	match tile_id:
		2:
			if pollution_level > 50:
				set_cell(tile_pos, 4, Vector2i(0, 0))
			elif pollution_level > 20:
				set_cell(tile_pos, 3, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 2, Vector2i(0, 0))
		3:
			if pollution_level > 50:
				set_cell(tile_pos, 4, Vector2i(0, 0))
			elif pollution_level < 20:
				set_cell(tile_pos, 2, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 3, Vector2i(0, 0))
		4:
			if pollution_level < 50:
				set_cell(tile_pos, 3, Vector2i(0, 0))
			elif pollution_level < 20:
				set_cell(tile_pos, 2, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 4, Vector2i(0, 0))
		5:
			if pollution_level > 60:
				set_cell(tile_pos, 8, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 7, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 6, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 5, Vector2i(0, 0))
		6:
			if pollution_level > 60:
				set_cell(tile_pos, 8, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 7, Vector2i(0, 0))
			elif pollution_level < 15:
				set_cell(tile_pos, 5, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 6, Vector2i(0, 0))
		7:
			if pollution_level > 60:
				set_cell(tile_pos, 8, Vector2i(0, 0))
			elif pollution_level < 25:
				set_cell(tile_pos, 6, Vector2i(0, 0))
			elif pollution_level < 15:
				set_cell(tile_pos, 5, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 7, Vector2i(0, 0))
		8:
			if pollution_level < 60:
				set_cell(tile_pos, 7, Vector2i(0, 0))
			elif pollution_level < 25:
				set_cell(tile_pos, 6, Vector2i(0, 0))
			elif pollution_level < 15:
				set_cell(tile_pos, 5, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 8, Vector2i(0, 0))
		9:
			if pollution_level > 17:
				set_cell(tile_pos, 10, Vector2i(0, 0))
				if(turns_till_growth == 3):
					set_cell(tile_pos, 11, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 9, Vector2i(0, 0))
				if(turns_till_growth == 3):
					set_cell(tile_pos, 11, Vector2i(0, 0))
		10:
			if pollution_level > 17:
				set_cell(tile_pos, 10, Vector2i(0, 0))
				if(turns_till_growth == 3):
					set_cell(tile_pos, 12, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 9, Vector2i(0, 0))
				if(turns_till_growth == 3):
					set_cell(tile_pos, 12, Vector2i(0, 0))
		11:
			if pollution_level > 58:
				set_cell(tile_pos, 14, Vector2i(0, 0))
			elif pollution_level > 28:
				set_cell(tile_pos, 13, Vector2i(0, 0))
			elif pollution_level > 18:
				set_cell(tile_pos, 12, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 11, Vector2i(0, 0))
		12:
			if pollution_level > 58:
				set_cell(tile_pos, 14, Vector2i(0, 0))
			elif pollution_level > 28:
				set_cell(tile_pos, 13, Vector2i(0, 0))
			elif pollution_level > 18:
				set_cell(tile_pos, 12, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 11, Vector2i(0, 0))
		13:
			if pollution_level > 58:
				set_cell(tile_pos, 14, Vector2i(0, 0))
			elif pollution_level > 28:
				set_cell(tile_pos, 13, Vector2i(0, 0))
			elif pollution_level > 18:
				set_cell(tile_pos, 12, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 11, Vector2i(0, 0))
		14:
			if pollution_level > 58:
				set_cell(tile_pos, 14, Vector2i(0, 0))
			elif pollution_level > 28:
				set_cell(tile_pos, 13, Vector2i(0, 0))
			elif pollution_level > 18:
				set_cell(tile_pos, 12, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 11, Vector2i(0, 0))
		15:
			if pollution_level > 62:
				set_cell(tile_pos, 18, Vector2i(0, 0))
			elif pollution_level > 32:
				set_cell(tile_pos, 17, Vector2i(0, 0))
			elif pollution_level > 22:
				set_cell(tile_pos, 16, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 15, Vector2i(0, 0))
		16:
			if pollution_level > 62:
				set_cell(tile_pos, 18, Vector2i(0, 0))
			elif pollution_level > 32:
				set_cell(tile_pos, 17, Vector2i(0, 0))
			elif pollution_level > 22:
				set_cell(tile_pos, 16, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 15, Vector2i(0, 0))
		17:
			if pollution_level > 62:
				set_cell(tile_pos, 18, Vector2i(0, 0))
			elif pollution_level > 32:
				set_cell(tile_pos, 17, Vector2i(0, 0))
			elif pollution_level > 22:
				set_cell(tile_pos, 16, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 15, Vector2i(0, 0))
		18:
			if pollution_level > 62:
				set_cell(tile_pos, 18, Vector2i(0, 0))
			elif pollution_level > 32:
				set_cell(tile_pos, 17, Vector2i(0, 0))
			elif pollution_level > 22:
				set_cell(tile_pos, 16, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 15, Vector2i(0, 0))
		19:
			if pollution_level > 50:
				set_cell(tile_pos, 22, Vector2i(0, 0))
			elif pollution_level > 20:
				set_cell(tile_pos, 21, Vector2i(0, 0))
			elif pollution_level > 10:
				set_cell(tile_pos, 20, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 19, Vector2i(0, 0))
		20:
			if pollution_level > 50:
				set_cell(tile_pos, 22, Vector2i(0, 0))
			elif pollution_level > 20:
				set_cell(tile_pos, 21, Vector2i(0, 0))
			elif pollution_level > 10:
				set_cell(tile_pos, 20, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 19, Vector2i(0, 0))
		21:
			if pollution_level > 50:
				set_cell(tile_pos, 22, Vector2i(0, 0))
			elif pollution_level > 20:
				set_cell(tile_pos, 21, Vector2i(0, 0))
			elif pollution_level > 10:
				set_cell(tile_pos, 20, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 19, Vector2i(0, 0))
		22:
			if pollution_level > 50:
				set_cell(tile_pos, 22, Vector2i(0, 0))
			elif pollution_level > 20:
				set_cell(tile_pos, 21, Vector2i(0, 0))
			elif pollution_level > 10:
				set_cell(tile_pos, 20, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 19, Vector2i(0, 0))
		23:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 25, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 24, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 23, Vector2i(0, 0))
		24:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 25, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 24, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 23, Vector2i(0, 0))
		25:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 25, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 24, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 23, Vector2i(0, 0))
		26:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 25, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 24, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 23, Vector2i(0, 0))
		27:
			if pollution_level > 60:
				set_cell(tile_pos, 30, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 29, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 28, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 27, Vector2i(0, 0))
		28:
			if pollution_level > 60:
				set_cell(tile_pos, 30, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 29, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 28, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 27, Vector2i(0, 0))
		29:
			if pollution_level > 60:
				set_cell(tile_pos, 30, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 29, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 28, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 27, Vector2i(0, 0))
		30:
			if pollution_level > 60:
				set_cell(tile_pos, 30, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 29, Vector2i(0, 0))
			elif pollution_level > 15:
				set_cell(tile_pos, 28, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 27, Vector2i(0, 0))
		31:
			if pollution_level > 80:
				set_cell(tile_pos, 34, Vector2i(0, 0))
			elif pollution_level > 50:
				set_cell(tile_pos, 33, Vector2i(0, 0))
			elif pollution_level > 30:
				set_cell(tile_pos, 32, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 31, Vector2i(0, 0))
		32:
			if pollution_level > 80:
				set_cell(tile_pos, 34, Vector2i(0, 0))
			elif pollution_level > 50:
				set_cell(tile_pos, 33, Vector2i(0, 0))
			elif pollution_level > 30:
				set_cell(tile_pos, 32, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 31, Vector2i(0, 0))
		33:
			if pollution_level > 80:
				set_cell(tile_pos, 34, Vector2i(0, 0))
			elif pollution_level > 50:
				set_cell(tile_pos, 33, Vector2i(0, 0))
			elif pollution_level > 30:
				set_cell(tile_pos, 32, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 31, Vector2i(0, 0))
		34:
			if pollution_level > 80:
				set_cell(tile_pos, 34, Vector2i(0, 0))
			elif pollution_level > 50:
				set_cell(tile_pos, 33, Vector2i(0, 0))
			elif pollution_level > 30:
				set_cell(tile_pos, 32, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 31, Vector2i(0, 0))
		35:
			if pollution_level > 68:
				set_cell(tile_pos, 38, Vector2i(0, 0))
			elif pollution_level > 45:
				set_cell(tile_pos, 37, Vector2i(0, 0))
			elif pollution_level > 30:
				set_cell(tile_pos, 36, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 35, Vector2i(0, 0))
		36:
			if pollution_level > 68:
				set_cell(tile_pos, 38, Vector2i(0, 0))
			elif pollution_level > 45:
				set_cell(tile_pos, 37, Vector2i(0, 0))
			elif pollution_level < 30:
				set_cell(tile_pos, 35, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 36, Vector2i(0, 0))
		37:
			if pollution_level > 68:
				set_cell(tile_pos, 38, Vector2i(0, 0))
			elif pollution_level < 45:
				set_cell(tile_pos, 36, Vector2i(0, 0))
			elif pollution_level < 30:
				set_cell(tile_pos, 35, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 37, Vector2i(0, 0))
		38:
			if pollution_level < 68:
				set_cell(tile_pos, 37, Vector2i(0, 0))
			elif pollution_level < 45:
				set_cell(tile_pos, 36, Vector2i(0, 0))
			elif pollution_level < 30:
				set_cell(tile_pos, 35, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 38, Vector2i(0, 0))
		39:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level > 45:
				set_cell(tile_pos, 41, Vector2i(0, 0))
			elif pollution_level > 25:
				set_cell(tile_pos, 40, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 39, Vector2i(0, 0))
		40:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level > 45:
				set_cell(tile_pos, 41, Vector2i(0, 0))
			elif pollution_level < 25:
				set_cell(tile_pos, 39, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 40, Vector2i(0, 0))
		41:
			if pollution_level > 60:
				set_cell(tile_pos, 26, Vector2i(0, 0))
			elif pollution_level < 45:
				set_cell(tile_pos, 40, Vector2i(0, 0))
			elif pollution_level < 25:
				set_cell(tile_pos, 39, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 41, Vector2i(0, 0))
		42: 
			if pollution_level > 35:
				set_cell(tile_pos, 43, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 42, Vector2i(0, 0))
		43: 
			if pollution_level < 35:
				set_cell(tile_pos, 42, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 43, Vector2i(0, 0))

func update_hover_label():
	var mouse_pos = get_global_mouse_position()
	var tile_pos = local_to_map(mouse_pos)
	var tile_id = get_cell_source_id(tile_pos)
	if tile_id > 0 and pollution_levels.has(tile_pos):
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

func end_turn():
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id > 0:
			var pollution = pollution_levels[tile_pos]
			var thresholds = pollution_thresholds.get(tile_id, {})
			var state = determine_pollution_state(pollution, thresholds)
			set_tile_state(tile_pos, tile_id, state, pollution)
	update_pollution_ui()

func handle_turn():
	if isTurn:
		print("It's your turn! You can take actions.")
	else:
		print("It's Night, pollution may spread.")

func spread_pollution():
	if !isNight: return
	for tile_pos in pollution_levels.keys():
		var _pollution = pollution_levels[tile_pos]
		var pollution_delta = randi_range(0, 2)
		update_pollution(tile_pos ,pollution_delta)

func next_turn():
	isTurn = !isTurn
	isNight = !isNight  
	if isNight:
		spread_pollution()
		turns_till_growth += 1
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

func _process(_delta):
	if isTurn:
		update_hover_label()
