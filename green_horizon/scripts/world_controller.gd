### WORLD CONTROLLER ### FUNCTIONALITY SCRIPT

extends TileMapLayer

# Pollution States
const POLLUTION_CLEAN = 0
const POLLUTION_MILD = 1
const POLLUTION_POLLUTED = 2
const POLLUTION_UNINHABITABLE = 3

# Resources
const ENERGY = 0
const WOOD = 1
const METAL = 2
const RUBBER = 3
const RECYCABLES = 4

# Other Constants
const MAX_POLLUTION = 100
var total_tiles = 0
var isTurn = true
var isNight = false
var last_pollution_spread_time = -1
var turns_till_growth = 0

# Map Constraints
var left = -345
var right = 285
var top = -270
var bot = 330

# Dictionary
var pollution_levels = {}
var tile_resources_at_position = {}

# Tile Thresholds
var pollution_thresholds = {
	# NORMAL TILES
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
	# CITY
	42: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 35}, # C_CITY_1
	44: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 35}, # C_CITY_2
	46: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 38}, # C_CITY_3
	48: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 40}, # C_CITY_4
	50: {POLLUTION_CLEAN: 0, POLLUTION_POLLUTED: 45}, # C_CITY_5
	# UPGRADE TILES
	39: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 25, POLLUTION_POLLUTED: 45},  # C_REFINERY
	52: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 21, POLLUTION_POLLUTED: 37}, # C_MINE_1
	54: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 22, POLLUTION_POLLUTED: 38}, # C_MINE_2
	56: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 23, POLLUTION_POLLUTED: 39}, # C_MINE_3
	60: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 20, POLLUTION_POLLUTED: 35, POLLUTION_UNINHABITABLE: 60}, # C_PANEL_1
	64: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 20, POLLUTION_POLLUTED: 40, POLLUTION_UNINHABITABLE: 65}, # C_PANEL_2
	68: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 25, POLLUTION_POLLUTED: 45, POLLUTION_UNINHABITABLE: 70}, # C_PANEL_3
	72: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 28, POLLUTION_POLLUTED: 38, POLLUTION_UNINHABITABLE: 68}, # CD_MINE_1
	74: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 30, POLLUTION_POLLUTED: 45, POLLUTION_UNINHABITABLE: 70}, # CD_MINE_2
	78: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 10, POLLUTION_POLLUTED: 20, POLLUTION_UNINHABITABLE: 50}, # CW_PLANT_1
	81: {POLLUTION_CLEAN: 0, POLLUTION_MILD: 15, POLLUTION_POLLUTED: 25, POLLUTION_UNINHABITABLE: 55}, # CW_PLANT_2
}

# Tile Resources
var tile_resources = {
	6: [RECYCABLES],
	7: [RECYCABLES],
	8: [RECYCABLES],
	10: [RECYCABLES],
	11: [WOOD],
	12: [WOOD, RECYCABLES],
	13: [RECYCABLES],
	15: [WOOD],
	16: [RECYCABLES],
	17: [RECYCABLES],
	20: [RECYCABLES],
	21: [RECYCABLES],
	25: [RECYCABLES],
	29: [RECYCABLES],
	32: [RECYCABLES],
	33: [RECYCABLES],
	26: [RECYCABLES],
	37: [RECYCABLES],
	39: [ENERGY, RUBBER],
	40: [ENERGY, RUBBER, RECYCABLES],
	41: [RUBBER, RECYCABLES],
	44: [WOOD],
	45: [WOOD, RECYCABLES],
	46: [WOOD, RUBBER],
	47: [WOOD, RUBBER, RECYCABLES],
	48: [WOOD, METAL, RUBBER],
	49: [WOOD, METAL, RUBBER, RECYCABLES],
	50: [ENERGY, WOOD, METAL, RUBBER, RECYCABLES],
	51: [ENERGY, WOOD, RUBBER, METAL, RECYCABLES],
	52: [METAL],
	53: [METAL, RECYCABLES],
	54: [METAL, WOOD],
	55: [METAL, WOOD, RECYCABLES],
	56: [METAL, WOOD],
	57: [METAL, WOOD, RECYCABLES],
	60: [ENERGY],
	61: [ENERGY, RECYCABLES],
	62: [ENERGY, RECYCABLES],
	64: [ENERGY],
	65: [ENERGY, RECYCABLES],
	66: [ENERGY, RECYCABLES],
	68: [ENERGY],
	69: [ENERGY, RECYCABLES],
	70: [ENERGY, RECYCABLES],
	72: [METAL],
	73: [METAL, RECYCABLES],
	74: [METAL],
	75: [METAL, RECYCABLES],
	76: [RECYCABLES],
	78: [ENERGY],
	79: [ENERGY, RECYCABLES],
	80: [RECYCABLES],
	81: [ENERGY],
	82: [ENERGY, RECYCABLES],
	83: [RECYCABLES],
}

var tile_names = {
	2: "River",
	3: "Water Plant",
	4: "Mine",
	5: "Desert Mine",
	6: "Solar Panel",
	15: "Hill",
	23: "Desert",
	27: "Desert Sands",
	35: "Mountain",
	39: "Refinery",
}
# Stockpile
var main_stockpile = {
	ENERGY: 0,
	WOOD: 0,
	METAL: 0,
	RUBBER: 0,
	RECYCABLES: 0
}

# Others
@onready var pollution_bar: TextureProgressBar = $"../../UI/TextureRect/HBoxContainer/PollutionBar"
@onready var display_state: Label = $"../../UI/TextureRect/HBoxContainer/DisplayState"
@onready var turn: Button = $"../../UI/TextureRect/HBoxContainer2/Turn"
@onready var popup_scene: PackedScene

# Resource Labels
@onready var energy_count: Label = $"../../UI/TextureRect/HBoxContainer/EnergyContainer/Count"
@onready var wood_count: Label = $"../../UI/TextureRect/HBoxContainer/WoodContainer/Count"
@onready var metal_count: Label = $"../../UI/TextureRect/HBoxContainer/MetalContainer/Count"
@onready var rubber_count: Label = $"../../UI/TextureRect/HBoxContainer/RubberContainer/Count"
@onready var recycables_count: Label = $"../../UI/TextureRect/HBoxContainer/RecycablesContainer/Count"


func initialize_pollution():
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

func initialize_resources():
	for x in range(left, right):
		for y in range(top, bot):
			var tile_pos = Vector2i(x, y)
			var tile_id = get_cell_source_id(tile_pos)
			if tile_id > 0:
				var initial_resources = {}
				if tile_resources.has(tile_id):
					for resource in tile_resources[tile_id]:
						initial_resources[resource] = randi_range(0, 1)
				tile_resources_at_position[tile_pos] = initial_resources

func update_resources_based_on_pollution(tile_pos: Vector2i, pollution_state: int):
	if tile_resources_at_position.has(tile_pos):
		var resources = tile_resources_at_position[tile_pos]
		match pollution_state:
			POLLUTION_CLEAN:
				pass
			POLLUTION_MILD, POLLUTION_POLLUTED:
				for resource in resources.keys():
					if resource == ENERGY:
						continue
					elif resource == RECYCABLES:
						resources[RECYCABLES] += 1
					else:
						resources[resource] = max(resources[resource] - 3, 0)

					main_stockpile[resource] += resources[resource]
			POLLUTION_UNINHABITABLE:
				for resource in resources.keys():
					resources[resource] = 0
					main_stockpile[resource] = 0
		update_resource_ui()

func generate_resources():
	for tile_pos in tile_resources_at_position.keys():
		var resources = tile_resources_at_position[tile_pos]
		for resource in resources.keys():
			var generated = randi_range(0, 1)
			resources[resource] += generated
			main_stockpile[resource] += generated

	update_resource_ui()

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

func set_tile_state(tile_pos: Vector2i, tile_id: int, state: int, pollution_level: int):
	update_resources_based_on_pollution(tile_pos, state)
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
		44: 
			if pollution_level > 35:
				set_cell(tile_pos, 45, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 44, Vector2i(0, 0))
		45: 
			if pollution_level < 35:
				set_cell(tile_pos, 44, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 45, Vector2i(0, 0))
		46: 
			if pollution_level > 38:
				set_cell(tile_pos, 47, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 46, Vector2i(0, 0))
		47: 
			if pollution_level < 38:
				set_cell(tile_pos, 46, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 47, Vector2i(0, 0))
		48: 
			if pollution_level > 40:
				set_cell(tile_pos, 49, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 48, Vector2i(0, 0))
		49: 
			if pollution_level < 40:
				set_cell(tile_pos, 48, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 49, Vector2i(0, 0))
		50: 
			if pollution_level > 45:
				set_cell(tile_pos, 51, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 50, Vector2i(0, 0))
		51: 
			if pollution_level < 45:
				set_cell(tile_pos, 50, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 51, Vector2i(0, 0))

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

func update_ui_resources():
	var total_resources = {ENERGY: 0, WOOD: 0, METAL: 0, RUBBER: 0, RECYCABLES: 0}
	for resources in tile_resources_at_position.values():
		for resource in resources.items():
			for amount in resources.items():
				total_resources[resource] += amount

func update_resource_ui():
	energy_count.text = str(main_stockpile[ENERGY])
	wood_count.text = str(main_stockpile[WOOD])
	metal_count.text = str(main_stockpile[METAL])
	rubber_count.text = str(main_stockpile[RUBBER])
	recycables_count.text = str(main_stockpile[RECYCABLES])

func end_turn():
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id > 0:
			var pollution = pollution_levels[tile_pos]
			var thresholds = pollution_thresholds.get(tile_id, {})
			var state = determine_pollution_state(pollution, thresholds)
			set_tile_state(tile_pos, tile_id, state, pollution)
			update_resources_based_on_pollution(tile_pos, state)
	update_resource_ui()

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
		generate_resources()
		turns_till_growth += 1
		update_resource_ui()
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
	initialize_resources()
	update_resource_ui()
	handle_turn()
	turn.connect("pressed", Callable(self, "_on_turn_button_toggled"))

func _process(_delta):
	if isTurn:
		update_hover_label()
