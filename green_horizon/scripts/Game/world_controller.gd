### WORLD CONTROLLER ### FUNCTIONALITY SCRIPT
class_name world_controller

extends TileMapLayer

signal new_turn
signal win
signal lose

# Pollution States
enum Pollution { CLEAN, MILD, POLLUTED, UNINHABITABLE }
# Resources
enum Resources { ENERGY, WOOD, METAL, RUBBER, RECYCABLES }

var tile_levels = {
	42: 1,  # City level 1
	44: 2,  # City level 2
	46: 3,  # City level 3
	48: 4,  # City level 4
	50: 5,  # City level 5
	52: 1,  # Hill mine level 1
	54: 2,  # Hill mine level 2
	56: 3,  # Hill mine level 3
	60: 1,  # Solar panel level 1
	64: 2,  # Solar panel level 2
	68: 3,  # Solar panel level 3
	72: 1,  # Mountain mine level 1
	74: 2,  # Mountain mine level 2
	78: 1,  # Water plant level 1
	81: 2,  # Water plant level 2
	39: 1   # Refinery level 1
}

# Other Constants
const MAX_POLLUTION = 100
const POLLUTION_REDUCTION_RATE = 0.005
var total_tiles = 0
var isTurn = true
var isNight = false
var last_pollution_spread_time = -1
var turns_till_growth = 0
var tile_pos: Vector2i
var tile_id: int
var first_turn_after_load = false

# Map Constraints
var left = -345
var right = 285
var top = -270
var bot = 330

# Dictionary
var pollution_levels = {}
var tile_resources_at_position = {}
var total_resources = {Resources.ENERGY: 0, Resources.WOOD: 0, Resources.METAL: 0, Resources.RUBBER: 0, Resources.RECYCABLES: 0}

# Tile Thresholds
var pollution_thresholds = {
	Pollution.CLEAN: 0,
	Pollution.MILD: 20,
	Pollution.POLLUTED: 50,
	Pollution.UNINHABITABLE: 80
}

# Tile Resources
var tile_resources = {
	6: [Resources.RECYCABLES],
	7: [Resources.RECYCABLES],
	8: [Resources.RECYCABLES],
	10: [Resources.RECYCABLES],
	11: [Resources.WOOD],
	12: [Resources.WOOD, Resources.RECYCABLES],
	13: [Resources.RECYCABLES],
	15: [Resources.WOOD],
	16: [Resources.RECYCABLES],
	17: [Resources.RECYCABLES],
	20: [Resources.RECYCABLES],
	21: [Resources.RECYCABLES],
	25: [Resources.RECYCABLES],
	29: [Resources.RECYCABLES],
	32: [Resources.RECYCABLES],
	33: [Resources.RECYCABLES],
	26: [Resources.RECYCABLES],
	37: [Resources.RECYCABLES],
	39: [Resources.ENERGY, Resources.RUBBER],
	40: [Resources.ENERGY, Resources.RUBBER, Resources.RECYCABLES],
	41: [Resources.RUBBER, Resources.RECYCABLES],
	44: [Resources.WOOD],
	45: [Resources.WOOD, Resources.RECYCABLES],
	46: [Resources.WOOD, Resources.RUBBER],
	47: [Resources.WOOD, Resources.RUBBER, Resources.RECYCABLES],
	48: [Resources.WOOD, Resources.METAL, Resources.RUBBER],
	49: [Resources.WOOD, Resources.METAL, Resources.RUBBER, Resources.RECYCABLES],
	50: [Resources.ENERGY, Resources.WOOD, Resources.METAL, Resources.RUBBER, Resources.RECYCABLES],
	51: [Resources.ENERGY, Resources.WOOD, Resources.RUBBER, Resources.METAL, Resources.RECYCABLES],
	52: [Resources.METAL],
	53: [Resources.METAL, Resources.RECYCABLES],
	54: [Resources.METAL, Resources.WOOD],
	55: [Resources.METAL, Resources.WOOD, Resources.RECYCABLES],
	56: [Resources.METAL, Resources.WOOD],
	57: [Resources.METAL, Resources.WOOD, Resources.RECYCABLES],
	60: [Resources.ENERGY],
	61: [Resources.ENERGY, Resources.RECYCABLES],
	62: [Resources.ENERGY, Resources.RECYCABLES],
	64: [Resources.ENERGY],
	65: [Resources.ENERGY, Resources.RECYCABLES],
	66: [Resources.ENERGY, Resources.RECYCABLES],
	68: [Resources.ENERGY],
	69: [Resources.ENERGY, Resources.RECYCABLES],
	70: [Resources.ENERGY, Resources.RECYCABLES],
	72: [Resources.METAL],
	73: [Resources.METAL, Resources.RECYCABLES],
	74: [Resources.METAL],
	75: [Resources.METAL, Resources.RECYCABLES],
	76: [Resources.RECYCABLES],
	78: [Resources.ENERGY],
	79: [Resources.ENERGY, Resources.RECYCABLES],
	80: [Resources.RECYCABLES],
	81: [Resources.ENERGY],
	82: [Resources.ENERGY, Resources.RECYCABLES],
	83: [Resources.RECYCABLES],
}

# Stockpile
var main_stockpile = {
	Resources.ENERGY: 0,
	Resources.WOOD: 0,
	Resources.METAL: 0,
	Resources.RUBBER: 0,
	Resources.RECYCABLES: 0
}

var building_costs = {
	"hill_mine": {Resources.ENERGY: 5, Resources.WOOD: 30, Resources.METAL: 0, Resources.RUBBER: 10, Resources.RECYCABLES: 10},
	"desert_mine": {Resources.WOOD: 150, Resources.METAL: 40, Resources.ENERGY: 5, Resources.RUBBER: 20},
	"solar_panel": {Resources.METAL: 30, Resources.RECYCABLES: 100, Resources.ENERGY: 30, Resources.RUBBER: 25},
	"water_plant": {Resources.WOOD: 200, Resources.METAL: 50, Resources.RECYCABLES: 100, Resources.ENERGY: 25, Resources.RUBBER: 15},
	"refinery": {Resources.WOOD: 70, Resources.METAL: 20, Resources.RECYCABLES: 70, Resources.ENERGY: 50, Resources.RUBBER: 15},
	"city": {Resources.ENERGY: 10, Resources.WOOD: 50, Resources.METAL: 30, Resources.RUBBER: 20, Resources.RECYCABLES: 30}
}

var building_to_tile_id = {
	"hill_mine": 52,
	"desert_mine": 72,
	"solar_panel": 60,
	"water_plant": 78,
	"refinery": 39,
	"city": [42, 44, 46, 48, 50]
}

var building_counts = {
	"hill_mine": 0,
	"desert_mine": 0,
	"solar_panel": 0,
	"water_plant": 0,
	"city": 0,
	"refinery": 0
}

# Preloads
@onready var tile_map: TileMap = $".."

# Others
@onready var pollution_bar: TextureProgressBar = $"../../UI/TextureRect/HBoxContainer/PollutionBar"
@onready var display_state: Label = $"../../UI/TextureRect/HBoxContainer/DisplayState"
@onready var turn: Button = $"../../UI/TextureRect/HBoxContainer2/Turn"

# Resource Labels
@onready var energy_count: Label = $"../../UI/TextureRect/HBoxContainer/EnergyContainer/Count"
@onready var wood_count: Label = $"../../UI/TextureRect/HBoxContainer/WoodContainer/Count"
@onready var metal_count: Label = $"../../UI/TextureRect/HBoxContainer/MetalContainer/Count"
@onready var rubber_count: Label = $"../../UI/TextureRect/HBoxContainer/RubberContainer/Count"
@onready var recycables_count: Label = $"../../UI/TextureRect/HBoxContainer/RecycablesContainer/Count"

@onready var notebook_panel: Control = $"../../UI/NotebookPanel"

func initialize_pollution():
	total_tiles = 0
	for x in range(left, right):
		for y in range(top, bot):
			var tile_pos = Vector2i(x, y)
			var tile_id = get_cell_source_id(tile_pos)
			if tile_id > 0:
				var pollution = randi_range(0, 20)
				pollution_levels[tile_pos] = pollution
				var state = determine_pollution_state(pollution)
				set_tile_state(tile_pos, tile_id, state, pollution)
				total_tiles += 1
	update_pollution_ui()

func update_ui_resources():
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id > 0:
			var pollution_level = pollution_levels[tile_pos]
			var resources = tile_resources.get(tile_id, [])
			for resource in resources:
				var resource_amount = get_resource_amount(resource, pollution_level)
				main_stockpile[resource] += resource_amount
	update_resource_ui()

func get_resource_amount(resource: int, pollution_level: int) -> int:
	var resource_value = 1
	
	if resource == Resources.RECYCABLES:
		if pollution_level < pollution_thresholds[Pollution.POLLUTED]:
			return 0
		return int(resource_value * (1 + pollution_level * 0.05))
	if pollution_level > 0:
		var reduction_factor = 1.0 / (1.0 + (pollution_level * POLLUTION_REDUCTION_RATE))
		resource_value = int(resource_value * reduction_factor)
	return resource_value

func update_pollution(tile_pos, pollution_delta: int):
	if pollution_levels.has(tile_pos):
		pollution_levels[tile_pos] = clamp(pollution_levels[tile_pos] + pollution_delta, 0, MAX_POLLUTION)
		var state = determine_pollution_state(pollution_levels[tile_pos])
		set_tile_state(tile_pos, get_cell_source_id(tile_pos), state, pollution_levels[tile_pos])

func determine_pollution_state(pollution_level: int) -> Pollution:
	if pollution_level >= pollution_thresholds[Pollution.UNINHABITABLE]:
		return Pollution.UNINHABITABLE
	elif pollution_level >= pollution_thresholds[Pollution.POLLUTED]:
		return Pollution.POLLUTED
	elif pollution_level >= pollution_thresholds[Pollution.MILD]:
		return Pollution.MILD
	return Pollution.CLEAN

func initialize_tile_resources():
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id > 0:
			var resources = tile_resources.get(tile_id, [])
			tile_resources_at_position[tile_pos] = {}
			for resource in resources:
				tile_resources_at_position[tile_pos][resource] = randf_range(0.5, 1.5)

func generate_resources():
	for tile_pos in tile_resources_at_position.keys():
		var tile_id = get_cell_source_id(tile_pos)
		var pollution_level = pollution_levels.get(tile_pos, 0)

		if tile_id in tile_resources:
			for resource in tile_resources[tile_id]:
				if tile_resources_at_position.has(tile_pos) and tile_resources_at_position[tile_pos].has(resource):
					var base_amount = tile_resources_at_position[tile_pos][resource]
					var building_level = tile_levels.get(tile_id, 1)

					if tile_id == building_to_tile_id["hill_mine"]:
						base_amount = base_amount * building_level

					if tile_id == building_to_tile_id["desert_mine"]:
						base_amount = base_amount * building_level

					if tile_id == building_to_tile_id["solar_panel"]:
						base_amount = base_amount * building_level

					var final_amount = base_amount * (1 - (pollution_level * POLLUTION_REDUCTION_RATE))

					if resource == Resources.RECYCABLES:
						final_amount = base_amount * (1 + pollution_level * 0.05)

					final_amount = max(0, int(final_amount))
					main_stockpile[resource] += final_amount

	update_resource_ui()

func apply_pollution_reduction():
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		var pollution_reduction = 0

		if tile_id == building_to_tile_id["water_plant"]:
			var building_level = tile_levels.get(tile_pos, 1)
			pollution_reduction = 0.5 * building_level

		if tile_id in building_to_tile_id["city"]:
			var building_level = tile_levels.get(tile_pos, 1)
			if building_level > 3:
				pollution_reduction = 1.5 * (building_level - 3)

		pollution_levels[tile_pos] = max(0, pollution_levels[tile_pos] - pollution_reduction)

func set_tile_state(tile_pos, tile_id, state: int, pollution_level: int):
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
			if pollution_level > 80:
				set_cell(tile_pos, 8, Vector2i(0, 0))
			elif pollution_level > 50:
				set_cell(tile_pos, 7, Vector2i(0, 0))
			elif pollution_level > 20:
				set_cell(tile_pos, 6, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 5, Vector2i(0, 0))
		6:
			if pollution_level > 80:
				set_cell(tile_pos, 8, Vector2i(0, 0))
			elif pollution_level > 50:
				set_cell(tile_pos, 7, Vector2i(0, 0))
			elif pollution_level < 20:
				set_cell(tile_pos, 5, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 6, Vector2i(0, 0))
		7:
			if pollution_level > 80:
				set_cell(tile_pos, 8, Vector2i(0, 0))
			elif pollution_level < 50:
				set_cell(tile_pos, 6, Vector2i(0, 0))
			elif pollution_level < 20:
				set_cell(tile_pos, 5, Vector2i(0, 0))
			else:
				set_cell(tile_pos, 7, Vector2i(0, 0))
		8:
			if pollution_level < 80:
				set_cell(tile_pos, 7, Vector2i(0, 0))
			elif pollution_level < 50:
				set_cell(tile_pos, 6, Vector2i(0, 0))
			elif pollution_level < 20:
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

func update_resource_ui():
	energy_count.text = str(main_stockpile[Resources.ENERGY])
	wood_count.text = str(main_stockpile[Resources.WOOD])
	metal_count.text = str(main_stockpile[Resources.METAL])
	rubber_count.text = str(main_stockpile[Resources.RUBBER])
	recycables_count.text = str(main_stockpile[Resources.RECYCABLES])

func end_turn():
	generate_resources()
	apply_pollution_reduction()
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id > 0:
			var pollution = pollution_levels[tile_pos]
			var state = determine_pollution_state(pollution)
			set_tile_state(tile_pos, tile_id, state, pollution)
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
		var pollution_delta = randi_range(0, 1)
		update_pollution(tile_pos ,pollution_delta)

func upgrade_tile(tile_type: String, valid_tile_ids: Array, upgrade_path: Array, cost: Dictionary):
	var upgradeable_tiles = []
	var new_tiles = []

	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		if tile_id in valid_tile_ids:
			new_tiles.append(tile_pos)
		elif tile_id in upgrade_path and tile_id != upgrade_path[-1]:
			upgradeable_tiles.append(tile_pos)

	var target_tile = null
	if not upgradeable_tiles.is_empty():
		target_tile = upgradeable_tiles.pick_random()
	else:
		target_tile = new_tiles.pick_random() if not new_tiles.is_empty() else null

	if target_tile == null:
		return

	var current_tile_id = get_cell_source_id(target_tile)
	var next_tile_id = upgrade_path[upgrade_path.find(current_tile_id) + 1] if current_tile_id in upgrade_path else upgrade_path[0]

	for resource in cost.keys():
		if main_stockpile.get(resource, 0) < cost[resource]:
			return

	for resource in cost.keys():
		main_stockpile[resource] -= cost[resource]

	set_cell(target_tile, next_tile_id, Vector2i(0, 0))

	var surrounding_pollution = pollution_levels.get(target_tile, 0)
	var new_pollution_level = max(surrounding_pollution - 10, 0)
	pollution_levels[target_tile] = new_pollution_level

	initialize_tile_resources()
	update_resource_ui()

func _on_build_refinery():
	print("Received signal: build_refinery")
	upgrade_tile("refinery", [23, 24], [39], building_costs["refinery"])

func _on_build_water():
	print("Received signal: build_water")
	upgrade_tile("water_plant", [19, 20], [78, 81], building_costs["water_plant"])

func _on_build_hill():
	print("Received signal: build_hill")
	upgrade_tile("hill_mine", [15, 16], [52, 54, 56], building_costs["hill_mine"])

func _on_build_mountain():
	print("Received signal: build_mountain")
	upgrade_tile("mountain_mine", [35, 36], [72, 74], building_costs["desert_mine"])

func _on_build_solar():
	print("Received signal: build_solar")
	upgrade_tile("solar_panel", [27, 28], [60, 64, 68], building_costs["solar_panel"])

func _on_build_city():
	print("Received signal: build_city")
	upgrade_tile("city", [42], [44, 46, 48, 50], building_costs["refinery"])

func check_game_state():
	building_counts = {
		"hill_mine": 0,
		"desert_mine": 0,
		"solar_panel": 0,
		"water_plant": 0,
		"city": 0,
		"refinery": 0
	}
	
	# Count buildings (keeping your existing code)
	for tile_pos in pollution_levels.keys():
		var tile_id = get_cell_source_id(tile_pos)
		
		if tile_id in [52, 54, 56]:
			building_counts["hill_mine"] += 1
		
		elif tile_id in [72, 74]:
			building_counts["desert_mine"] += 1
		
		elif tile_id in [60, 64, 68]:
			building_counts["solar_panel"] += 1
		
		elif tile_id in [78, 81]:
			building_counts["water_plant"] += 1
		
		elif tile_id in [42, 44, 46, 48, 50]:
			building_counts["city"] += 1
			if tile_id == 50:
				building_counts["max_city"] = true
		
		elif tile_id == 39:
			building_counts["refinery"] += 1
	
	var total_pollution = calculate_total_pollution()
	var max_possible_pollution = total_tiles * MAX_POLLUTION
	var pollution_percentage = float(total_pollution) / max_possible_pollution * 100
	
	var uninhabitable_tiles = 0
	for tile_pos in pollution_levels.keys():
		if pollution_levels[tile_pos] >= pollution_thresholds[Pollution.UNINHABITABLE]:
			uninhabitable_tiles += 1
	
	var uninhabitable_percentage = float(uninhabitable_tiles) / total_tiles * 100

	if pollution_percentage > 80.0:
		print("LOSE CONDITION MET: Global pollution critical at " + str(pollution_percentage) + "%")
		lose_game()
		return


	var has_enough_buildings = (
		building_counts["hill_mine"] >= 3 and
		building_counts["desert_mine"] >= 3 and
		building_counts["solar_panel"] >= 3 and
		building_counts["water_plant"] >= 3
	)
	
	var has_max_city = building_counts.get("max_city", false)
	var pollution_under_limit = pollution_percentage < 15.0
	
	if has_enough_buildings and has_max_city and pollution_under_limit:
		print("WIN CONDITIONS MET!")
		win_game()

func _on_load_completed():
	print("Number of tile positions with resources: ", tile_resources_at_position.size())
	
	for tile_pos in tile_resources_at_position.keys():
		var resources_at_pos = tile_resources_at_position[tile_pos]
		var fixed_resources = {}
		for key in resources_at_pos.keys():
			var resource_key = key
			if typeof(key) == TYPE_STRING:
				resource_key = int(key)
			fixed_resources[resource_key] = resources_at_pos[key]
		tile_resources_at_position[tile_pos] = fixed_resources
	
	var fixed_stockpile = {}
	for key in main_stockpile.keys():
		var resource_key = key
		if typeof(key) == TYPE_STRING:
			resource_key = int(key)
		fixed_stockpile[resource_key] = main_stockpile[key]
	main_stockpile = fixed_stockpile
	
	print("Current stockpile before generation:", main_stockpile)
	generate_resources()
	print("Current stockpile after generation:", main_stockpile)
	update_resource_ui()
	handle_turn()
	first_turn_after_load = true

func next_turn():
	isTurn = !isTurn
	isNight = !isNight
	if isNight or first_turn_after_load:
		end_turn()
		spread_pollution()
		turns_till_growth += 1
		update_resource_ui()
		update_pollution_ui()
		check_game_state()
		first_turn_after_load = false
	update_turn_ui()
	emit_signal("new_turn")

func update_turn_ui():
	if isTurn:
		display_state.text = "It's your turn (Day)."
	else:
		display_state.text = "It's not your turn (Night)."

func lose_game():
	print("LOSE GAME FUNCTION CALLED")
	emit_signal("lose")
	get_tree().change_scene_to_file("res://scenes/Credits/lose_game.tscn")
	
func win_game():
	print("WIN GAME FUNCTION CALLED")
	emit_signal("win")
	get_tree().change_scene_to_file("res://scenes/Credits/win_game.tscn")

func get_tile_data() -> Dictionary:
	var tile_data = {}
	for tile_pos in pollution_levels.keys():
		tile_data[tile_pos] = {
			"id": get_cell_source_id(tile_pos),
			"pollution": pollution_levels[tile_pos],
			"resources": tile_resources_at_position.get(tile_pos, {}),
			"level": tile_levels.get(tile_pos, 1)
		}
	return tile_data

func _on_level_completed():
	for tile_pos in pollution_levels.keys():
		update_pollution(tile_pos, -20)

func _ready():
	add_to_group("world_controller")
	set_process_input(true)
	initialize_pollution()
	initialize_tile_resources()
	update_resource_ui()
	handle_turn()
	turn.connect("pressed", Callable(self, "_on_turn_button_toggled"))
	EventController.level_completed.connect(_on_level_completed)
	notebook_panel.connect("build_refinery", Callable(self, "_on_build_refinery"))
	notebook_panel.connect("build_water", Callable(self, "_on_build_water"))
	notebook_panel.connect("build_hill", Callable(self, "_on_build_hill"))
	notebook_panel.connect("build_mountain", Callable(self, "_on_build_mountain"))
	notebook_panel.connect("build_solar", Callable(self, "_on_build_solar"))
	notebook_panel.connect("build_city", Callable(self, "_on_build_city"))
	if not GameSaveManager.is_connected("load_completed", Callable(self, "_on_load_completed")):
		GameSaveManager.connect("load_completed", Callable(self, "_on_load_completed"))
	if GameController.returning_from_mission:
		GameSaveManager.load_game("autosave")
		GameController.returning_from_mission = false


func _process(_delta):
	if isTurn:
		update_hover_label()


func _on_turn_pressed() -> void:
	next_turn()
