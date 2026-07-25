class_name MapGenerator
extends Node

enum CellType { WATER, LAND }

@export_group("Ocean Settings")
@export var ocean_width: int = 500
@export var ocean_height: int = 400

@export_group("Base Map Settings")
@export var map_radius: int = 50
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
	autotiler = get_parent().get_node_or_null("DualGridAutotiler")
	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = noise_frequency
	
	noise_grass = FastNoiseLite.new()
	noise_grass.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_grass.frequency = grass_noise_frequency
	
	generate_new_map()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.physical_keycode == KEY_R:
			generate_new_map()


func _reposition_player(grid: Dictionary) -> void:
	var player = get_parent().get_node_or_null("Player")
	if not player: 
		return
		
	var spawn_cell := Vector2i(0, 0)
	
	if grid.get(spawn_cell, CellType.WATER) == CellType.WATER:
		var land_found := false
		for r in range(1, map_radius):
			var search_directions := [
				Vector2i(r, 0), Vector2i(-r, 0), Vector2i(0, r), Vector2i(0, -r),
				Vector2i(r, r), Vector2i(-r, r), Vector2i(r, -r), Vector2i(-r, -r)
			]
			for dir in search_directions:
				if grid.get(dir, CellType.WATER) == CellType.LAND:
					spawn_cell = dir
					land_found = true
					break
			if land_found:
				break
				
	var world_x := float(spawn_cell.x * tile_size + (tile_size / 2.0))
	var world_y := float(spawn_cell.y * tile_size + (tile_size / 2.0))
	
	player.position = Vector2(world_x, world_y)


func _init_seeds() -> void:
	noise.seed = randi()
	noise_grass.seed = randi()


func _generate_base_grid() -> Dictionary:
	var grid := {}
	var full_radius := map_radius + padding
	
	var half_w : int = floor(ocean_width / 2.0)
	var half_h : int = floor(ocean_height / 2.0)

	for x in range(-half_w, half_w + 1):
		for y in range(-half_h, half_h + 1):
			var cell := Vector2i(x, y)
			
			if abs(x) > full_radius or abs(y) > full_radius:
				grid[cell] = CellType.WATER
				continue
			
			var radial_gradient := 1.0 - (cell.length() / map_radius)
			var base_type := CellType.WATER
			
			if radial_gradient > 0.0:
				var noise_val := noise.get_noise_2dv(cell)
				var final_gradient := radial_gradient + (noise_val * noise_influence)
				if final_gradient >= threshold:
					base_type = CellType.LAND
			
			grid[cell] = base_type
				
	return grid


func _init_rivers() -> Array:
	var rivers := []
	
	for i in range(0, river_quantity):
		var river_angle := randf_range(0.0, PI * 2.0)
		var river_length := map_radius * RIVER_LENGTH_FACTOR
		var river_parts := randi_range(river_quantity + 1, river_quantity + 3)
		var step_size := river_length / river_parts
		var bridges: Array[float] = []
		for j in range(1, river_parts):
			var bridge_step := (j * step_size) - (river_length / 2)
			var jitter := randf_range(-step_size * BRIDGE_JITTER_FACTOR, step_size * BRIDGE_JITTER_FACTOR)
			bridges.append(bridge_step + jitter)
		
		var river := {
			"cos_a": cos(river_angle),
			"sin_a": sin(river_angle),
			"width": randi_range(river_avarage_width - 1, river_avarage_width + 1),
			"offset": randf_range(-map_radius * RIVER_AVG_OFFSET, map_radius * RIVER_AVG_OFFSET),
			"bridges": bridges
		}
		
		rivers.append(river)
	
	return rivers


func _carve_rivers(grid: Dictionary) -> void:
	var rivers := _init_rivers()
	
	for cell in grid:
		if grid[cell] == CellType.WATER:
			continue
			
		for river in rivers:
			if _check_cell_for_river(cell, river):
				grid[cell] = CellType.WATER
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
			var bridge_width := randi_range(3, bridge_avg_width + 2)
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
			if grid[cell] != CellType.LAND:
				continue
				
			var water_neighbors := 0
			for direction in DIRECTIONS_8:
				var neighbor: Vector2i = cell + direction
				
				if not grid.has(neighbor) or grid[neighbor] == CellType.WATER:
					water_neighbors += 1
			
			if water_neighbors >= 5:
				changes[cell] = CellType.WATER
		
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
	
	var centre := Vector2i(0, 0)
	if grid.get(centre, CellType.WATER) == CellType.WATER:
		var land_found := false
		for r in range(1, map_radius):
			var search_directions := [
				Vector2i(r, 0), Vector2i(-r, 0), Vector2i(0, r), Vector2i(0, -r),
				Vector2i(r, r), Vector2i(-r, r), Vector2i(r, -r), Vector2i(-r, -r)
			]
			for dir in search_directions:
				if grid.get(dir, CellType.WATER) == CellType.LAND:
					centre = dir
					land_found = true
					break
			if land_found:
				break
	
	if grid.get(centre, CellType.WATER) == CellType.WATER:
		return
		
	visited[centre] = true
	queue.append(centre)
	
	var queue_index := 0
	while queue_index < queue.size():
		var current: Vector2i = queue[queue_index]
		queue_index += 1
		
		for direction in DIRECTIONS_4:
			var neighbor: Vector2i = current + direction
			if grid.has(neighbor) and grid[neighbor] == CellType.LAND and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	
	for cell in grid:
		if grid[cell] == CellType.LAND and not visited.has(cell):
			grid[cell] = CellType.WATER


func _generate_terrain_biomes(grid: Dictionary) -> Dictionary:
	var terrain_map := {}
	for cell in grid:
		if grid[cell] == CellType.WATER:
			terrain_map[cell] = autotiler.ID_WATER
		else:
			var noise_val := noise_grass.get_noise_2dv(cell)
			if noise_val < -medium_grass_percentage:
				terrain_map[cell] = autotiler.ID_DARK_GRASS
			elif noise_val > medium_grass_percentage:
				terrain_map[cell] = autotiler.ID_LIGHT_GRASS
			else:
				terrain_map[cell] = autotiler.ID_MEDIUM_GRASS
	return terrain_map


func _fix_terrain_transitions(terrain_map: Dictionary) -> void:
	var keep_smoothing := true
	var safety_counter := 0
	
	while keep_smoothing:
		var changes := {}
		
		for cell in terrain_map:
			var cell_id: int = terrain_map[cell]
			if cell_id == autotiler.ID_WATER:
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
		autotiler.set_cell(cell, 0, Vector2i(tile_id, 0))


func generate_new_map() -> void:
	if not autotiler: return
	autotiler.clear()
	
	_init_seeds()
	
	var grid := _generate_base_grid()
	
	if river_quantity != 0:
		_carve_rivers(grid)
		_smooth_river_banks(grid)
		
	_filter_isolated_islands(grid)
		
	_reposition_player(grid)
		
	var terrain_map := _generate_terrain_biomes(grid)
	_fix_terrain_transitions(terrain_map)
	_draw_to_autotiler(terrain_map)
	
	autotiler.refresh_visual_layer()
