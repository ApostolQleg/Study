class_name MapGenerator
extends Node

signal world_generated(bounds: Rect2)

@export_group("Ocean Settings")
@export var ocean_width: int = 1600
@export var ocean_height: int = 900

@export_group("Base Map Settings")
@export var map_radius: int = 100
@export var padding: int = 5
@export var tile_size: int = 16
@export var threshold: float = 0.35

@export_group("Noise Settings")
@export var noise_frequency: float = 0.01
@export var noise_influence: float = 0.15
@export var grass_noise_frequency: float = 0.03

@export_group("Biomes & Smoothing")
@export var medium_grass_percentage: float = 0.20
@export var max_smoothing_passes: int = 15

@export_group("River Settings")
@export var river_quantity: int = 1
@export var river_avarage_width: int = 4
@export var bridge_avg_width: int = 4

const RIVER_AVG_OFFSET := 0.5
const RIVER_LENGTH_FACTOR := 1.5
const RIVER_WOBBLE_FREQUENCY := 4.0
const RIVER_WOBBLE_AMPLITUDE := 6.0

const BRIDGE_JITTER_FACTOR := 0.15

const DIRECTIONS_4: Array[Vector2i] = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]
const DIRECTIONS_8: Array[Vector2i] = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
		Vector2i.UP + Vector2i.LEFT, Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT, Vector2i.DOWN + Vector2i.RIGHT
	]

var noise: FastNoiseLite
var noise_grass: FastNoiseLite
var autotiler: DualGridAutotiler

func _ready() -> void:
	autotiler = Global.autotiler
	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = noise_frequency
	
	noise_grass = FastNoiseLite.new()
	noise_grass.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_grass.frequency = grass_noise_frequency

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("generate_map"):
		generate_new_map()

func _init_seeds() -> void:
	noise.seed = Global.rng.randi()
	noise_grass.seed = Global.rng.randi()

func _init_rivers() -> Array:
	var rivers: Array[Dictionary] = []
	
	for i in range(0, river_quantity):
		var river_angle := Global.rng.randf_range(0.0, PI * 2.0)
		var river_length := map_radius * RIVER_LENGTH_FACTOR
		var river_parts := Global.rng.randi_range(2, river_quantity + 3)
		var step_size := river_length / river_parts
		var bridges: Array[float] = []
		for j in range(1, river_parts):
			var bridge_step := (j * step_size) - (river_length / 2)
			var jitter := Global.rng.randf_range(-step_size * BRIDGE_JITTER_FACTOR, step_size * BRIDGE_JITTER_FACTOR)
			bridges.append(bridge_step + jitter)
		
		var river := {
			"cos_a": cos(river_angle),
			"sin_a": sin(river_angle),
			"width": Global.rng.randi_range(river_avarage_width - 1, river_avarage_width + 1),
			"offset": Global.rng.randf_range(-map_radius * RIVER_AVG_OFFSET, map_radius * RIVER_AVG_OFFSET),
			"bridges": bridges
		}
		
		rivers.append(river)
	
	return rivers

func _find_nearest_land(grid: Dictionary, start_cell: Vector2i = Vector2i.ZERO) -> Vector2i:
	if grid.get(start_cell, Util.CellType.WATER) == Util.CellType.LAND:
		return start_cell   
		   
	for r in range(1, map_radius):
		for dir in DIRECTIONS_8:
			var target_cell: Vector2i = start_cell + (dir * r)
			if grid.get(target_cell, Util.CellType.WATER) == Util.CellType.LAND:
				return target_cell
	
	return start_cell

func _generate_base_grid() -> Dictionary:
	var grid := {}
	var full_radius := map_radius + padding

	for x in range(-full_radius, full_radius + 1):
		for y in range(-full_radius, full_radius + 1):
			var cell := Vector2i(x, y)
			
			var radial_gradient := 1.0 - (cell.length() / float(map_radius))
			var base_type := Util.CellType.WATER
			
			if radial_gradient > 0.0:
				var noise_val := noise.get_noise_2dv(cell)
				var final_gradient := radial_gradient + (noise_val * noise_influence)
				if final_gradient >= threshold:
					base_type = Util.CellType.LAND
			
			grid[cell] = base_type
				
	return grid

func _carve_rivers(grid: Dictionary) -> void:
	var rivers := _init_rivers()
	
	for cell in grid:
		if grid[cell] == Util.CellType.WATER:
			continue
			
		for river in rivers:
			if _check_cell_for_river(cell, river):
				grid[cell] = Util.CellType.WATER
				break

func _check_cell_for_river(cell: Vector2i, river: Dictionary) -> bool:
	var distance_along_river: float = -cell.x * river["sin_a"] + cell.y * river["cos_a"]
	
	var distance_to_center: float = (cell.x * river["cos_a"] + cell.y * river["sin_a"]) - river["offset"]
	
	var max_possible_reach : float = (river["width"] / 2.0) + RIVER_WOBBLE_AMPLITUDE
	if abs(distance_to_center) > max_possible_reach:
		return false
	
	var wobble := noise.get_noise_1d(distance_along_river * RIVER_WOBBLE_FREQUENCY) * RIVER_WOBBLE_AMPLITUDE
	var final_distance := distance_to_center - wobble
	
	if abs(final_distance) <= river["width"] / 2.0:
		for bridge_pos in river["bridges"]:
			var bridge_width := Global.rng.randi_range(3, bridge_avg_width + 2)
			if abs(distance_along_river - bridge_pos) <= bridge_width / 2.0:
				return false
		return true
		
	return false

func _smooth_river_banks(grid: Dictionary) -> void:
	var keep_smoothing := true
	var safety_counter := 0
	
	while keep_smoothing:
		var changes := {}
		
		for cell in grid:
			if grid[cell] != Util.CellType.LAND:
				continue
				
			var water_neighbors := 0
			for direction in DIRECTIONS_8:
				var neighbor: Vector2i = cell + direction
				
				if not grid.has(neighbor) or grid[neighbor] == Util.CellType.WATER:
					water_neighbors += 1
			
			if water_neighbors >= 5:
				changes[cell] = Util.CellType.WATER
		
		if changes.is_empty():
			keep_smoothing = false
		else:
			for cell in changes:
				grid[cell] = changes[cell]
				
		safety_counter += 1
		if safety_counter > max_smoothing_passes:
			break

func _filter_isolated_islands(grid: Dictionary) -> void:
	var visited := {}
	var queue : Array[Vector2i] = []
	
	var centre := _find_nearest_land(grid)
	
	if grid.get(centre, Util.CellType.WATER) == Util.CellType.WATER:
		return
		
	visited[centre] = true
	queue.append(centre)
	
	var queue_index := 0
	while queue_index < queue.size():
		var current: Vector2i = queue[queue_index]
		queue_index += 1
		
		for direction in DIRECTIONS_4:
			var neighbor: Vector2i = current + direction
			if grid.has(neighbor) and grid[neighbor] == Util.CellType.LAND and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	
	for cell in grid:
		if grid[cell] == Util.CellType.LAND and not visited.has(cell):
			grid[cell] = Util.CellType.WATER

func _generate_terrain_biomes(grid: Dictionary) -> Dictionary:
	var terrain_map := {}
	for cell in grid:
		if grid[cell] == Util.CellType.WATER:
			terrain_map[cell] = Util.TerrainType.ID_WATER
		else:
			var noise_val := noise_grass.get_noise_2dv(cell)
			if noise_val < -medium_grass_percentage:
				terrain_map[cell] = Util.TerrainType.ID_DARK_GRASS
			elif noise_val > medium_grass_percentage:
				terrain_map[cell] = Util.TerrainType.ID_LIGHT_GRASS
			else:
				terrain_map[cell] = Util.TerrainType.ID_MEDIUM_GRASS
	return terrain_map

func _fix_terrain_transitions(terrain_map: Dictionary) -> void:
	var keep_smoothing := true
	var safety_counter := 0
	
	while keep_smoothing:
		var changes := {}
		
		for cell in terrain_map:
			var cell_id: int = terrain_map[cell]
			if cell_id == Util.TerrainType.ID_WATER:
				continue
				
			var max_possible := cell_id
			var min_possible := cell_id
			
			for direction in DIRECTIONS_8:
				var neighbor: Vector2i = cell + direction
				if not terrain_map.has(neighbor):
					continue
					
				var neighbor_id: int = terrain_map[neighbor]
				
				max_possible = min(max_possible, neighbor_id + 1)
				min_possible = max(min_possible, neighbor_id - 1)
			
			var target_id := cell_id
			target_id = max(target_id, min_possible)
			target_id = min(target_id, max_possible)
			
			if target_id != cell_id:
				changes[cell] = target_id
		
		if changes.is_empty():
			keep_smoothing = false
		else:
			for cell in changes:
				terrain_map[cell] = changes[cell]
				
		safety_counter += 1
		if safety_counter > max_smoothing_passes:
			break

func _draw_to_autotiler(terrain_map: Dictionary) -> void:
	for cell in terrain_map:
		var tile_id: int = terrain_map[cell]
		if tile_id != Util.TerrainType.ID_WATER:
			autotiler.set_cell(cell, 0, Vector2i(tile_id, 0))

func get_world_bounds() -> Rect2:
	var half_w_px := (ocean_width / 2.0) * tile_size
	var half_h_px := (ocean_height / 2.0) * tile_size
	var top_left := Vector2(-half_w_px, -half_h_px)
	var size := Vector2(ocean_width * tile_size, ocean_height * tile_size)
	return Rect2(top_left, size)

func _update_ocean_background(bounds: Rect2) -> void:
	var ocean_bg = get_parent().get_node_or_null("OceanBackground") as TextureRect
	if not ocean_bg:
		return
		
	ocean_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ocean_bg.stretch_mode = TextureRect.STRETCH_TILE
	ocean_bg.position = bounds.position
	ocean_bg.size = bounds.size

func generate_new_map() -> void:
	if not autotiler: return
	autotiler.clear()
	
	_init_seeds()
	
	var grid := _generate_base_grid()
	
	if river_quantity != 0:
		_carve_rivers(grid)
		_smooth_river_banks(grid)
		
	_filter_isolated_islands(grid)
		
	var terrain_map := _generate_terrain_biomes(grid)
	_fix_terrain_transitions(terrain_map)
	_draw_to_autotiler(terrain_map)
	
	autotiler.refresh_visual_layer()
	
	var bounds := get_world_bounds()
	_update_ocean_background(bounds)
	
	world_generated.emit(get_world_bounds())
