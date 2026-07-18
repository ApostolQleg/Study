class_name MapGenerator
extends Node

@export_group("Ocean Settings")
@export var ocean_width: int = 250
@export var ocean_height: int = 200

@export_group("Base Map Settings")
@export var map_radius: int = 50
@export var padding: int = 5
@export var tile_size: int = 16
@export var threshold: float = 0.35

@export_group("Noise Settings")
@export var noise_frequency: float = 0.01
@export var noise_influence: float = 0.15
@export var grass_noise_frequency: float = 0.03

@export_group("River Geometry")
@export var river_width_row: int = 4
@export var river_offset_row: float = 0.15
@export var river_parts_row: int = 2
@export var river_length_factor: float = 1.5
@export var river_wobble_frequency: float = 4.0
@export var river_wobble_amplitude: float = 6.0

@export_group("Bridges & Biomes")
@export var bridge_width: float = 3.0
@export var bridge_jitter_factor: float = 0.1
@export var medium_grass_percentage: float = 0.20
@export var max_smoothing_passes: int = 15

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
	
	if grid.get(spawn_cell, "water") == "water":
		var land_found := false
		for r in range(1, map_radius):
			var search_directions := [
				Vector2i(r, 0), Vector2i(-r, 0), Vector2i(0, r), Vector2i(0, -r),
				Vector2i(r, r), Vector2i(-r, r), Vector2i(r, -r), Vector2i(-r, -r)
			]
			for dir in search_directions:
				if grid.get(dir, "water") == "land":
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
	
	var river_angle := randf_range(0.0, PI * 2.0)
	var river_width := float(randi_range(river_width_row - 1, river_width_row + 1))
	var river_offset := randf_range(-map_radius * river_offset_row, map_radius * river_offset_row)
	
	var cos_a := cos(river_angle)
	var sin_a := sin(river_angle)
	
	var river_parts := randi_range(river_parts_row, river_parts_row + 1)
	var bridges_t: Array[float] = []
	
	var step_size := (map_radius * river_length_factor) / river_parts
	var half_river_span := map_radius * (river_length_factor / 2.0)
	
	for i in range(1, river_parts):
		var base_t := -half_river_span + (i * step_size)
		var jitter := randf_range(-step_size * bridge_jitter_factor, step_size * bridge_jitter_factor)
		bridges_t.append(base_t + jitter)

	for x in range(-half_w, half_w + 1):
		for y in range(-half_h, half_h + 1):
			var cell := Vector2i(x, y)
			
			if abs(x) > full_radius or abs(y) > full_radius:
				grid[cell] = "water"
				continue
			
			var radial_gradient := 1.0 - (cell.length() / map_radius)
			
			var base_type := "water"
			if radial_gradient > 0.0:
				var noise_val := noise.get_noise_2dv(cell)
				var final_gradient := radial_gradient + (noise_val * noise_influence)
				if final_gradient >= threshold:
					base_type = "land"
			
			var t := -cell.x * sin_a + cell.y * cos_a
			var wobble := noise.get_noise_1d(t * river_wobble_frequency) * river_wobble_amplitude
			var dist_to_river := cell.x * cos_a + cell.y * sin_a - river_offset + wobble
			
			if abs(dist_to_river) <= river_width / 2.0:
				var in_bridge := false
				for b_t in bridges_t:
					if abs(t - b_t) <= bridge_width / 2.0:
						in_bridge = true
						break
				
				if in_bridge:
					grid[cell] = base_type
				else:
					grid[cell] = "water"
			else:
				grid[cell] = base_type
				
	return grid


func _filter_isolated_islands(grid: Dictionary) -> void:
	var visited := {}
	var queue : Array[Vector2i] = []
	
	var centre := Vector2i(0, 0)
	if grid.get(centre, "water") == "water":
		var land_found := false
		for r in range(1, map_radius):
			var search_directions := [
				Vector2i(r, 0), Vector2i(-r, 0), Vector2i(0, r), Vector2i(0, -r),
				Vector2i(r, r), Vector2i(-r, r), Vector2i(r, -r), Vector2i(-r, -r)
			]
			for dir in search_directions:
				if grid.get(dir, "water") == "land":
					centre = dir
					land_found = true
					break
			if land_found:
				break
	
	if grid.get(centre, "water") == "water":
		return
		
	visited[centre] = true
	queue.append(centre)
	
	var directions: Array[Vector2i] = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]
	
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		
		for direction in directions:
			var neighbor: Vector2i = current + direction
			if grid.has(neighbor) and grid[neighbor] == "land" and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	
	for cell in grid:
		if grid[cell] == "land" and not visited.has(cell):
			grid[cell] = "water"


func _generate_terrain_biomes(grid: Dictionary) -> Dictionary:
	var terrain_map := {}
	for cell in grid:
		if grid[cell] == "water":
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
	var directions_8: Array[Vector2i] = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
		Vector2i.UP + Vector2i.LEFT, Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT, Vector2i.DOWN + Vector2i.RIGHT
	]
	
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
			
			for direction in directions_8:
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
	_filter_isolated_islands(grid)
	
	_reposition_player(grid)
	
	var terrain_map := _generate_terrain_biomes(grid)
	_fix_terrain_transitions(terrain_map)
	_draw_to_autotiler(terrain_map)
	
	autotiler.refresh_visual_layer()
