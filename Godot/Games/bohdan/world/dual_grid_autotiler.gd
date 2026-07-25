class_name DualGridAutotiler
extends TileMapLayer

var visual_layer: TileMapLayer:
	get:
		if not is_instance_valid(_visual_layer_cache):
			_visual_layer_cache = get_node_or_null("VisualLayer")
		return _visual_layer_cache

const BASE: int = 4 

const ID_WATER: int = 0
const ID_DARK_GRASS: int = 1
const ID_MEDIUM_GRASS: int = 2
const ID_LIGHT_GRASS: int = 3

const X_OFFSET_DARK: int = 0
const X_OFFSET_MEDIUM: int = 4 
const X_OFFSET_LIGHT: int = 8

var _visual_layer_cache: TileMapLayer = null

@onready var tile_to_source_array: Array[Vector2i] = _generate_tile_array()

func refresh_visual_layer() -> void:
	var layer := visual_layer
	if layer == null: 
		return
		
	layer.clear()
	
	var used_cells := get_used_cells()
	if used_cells.is_empty(): 
		return
		
	var cells_to_update := {}
	for cell in used_cells:
		cells_to_update[cell] = true
		cells_to_update[cell + Vector2i(1, 0)] = true
		cells_to_update[cell + Vector2i(0, 1)] = true
		cells_to_update[cell + Vector2i(1, 1)] = true
				
	for cell_key in cells_to_update.keys():
		var cell: Vector2i = cell_key
		var array_index := get_tile_index(cell)
		var atlas_coord := tile_to_source_array[array_index]
		layer.set_cell(cell, 0, atlas_coord)


func get_tile_index(coord: Vector2i) -> int:
	var c00 := _get_terrain_at(coord + Vector2i(-1, -1))
	var c01 := _get_terrain_at(coord + Vector2i(-1,  0))
	var c10 := _get_terrain_at(coord + Vector2i( 0, -1))
	var c11 := _get_terrain_at(coord + Vector2i( 0,  0))
	
	return (c00 * 64) + (c01 * 16) + (c10 * 4) + c11


func _get_terrain_at(coord: Vector2i) -> int:
	return _get_terrain_from_atlas(get_cell_atlas_coords(coord))


func _get_terrain_from_atlas(atlas: Vector2i) -> int:
	return atlas.x if atlas.x != -1 else ID_WATER


func _generate_tile_array() -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	arr.resize(256)
	arr.fill(Vector2i(0, 3))
	
	var template_4x4: Array[Vector2i] = [
		Vector2i(0, 3), Vector2i(1, 3), Vector2i(0, 2), Vector2i(1, 0),
		Vector2i(0, 0), Vector2i(3, 0), Vector2i(2, 3), Vector2i(1, 1),
		Vector2i(3, 3), Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 2),
		Vector2i(3, 2), Vector2i(2, 0), Vector2i(3, 1), Vector2i(2, 1)
	]
	
	var transitions := [
		[ID_WATER, ID_DARK_GRASS, X_OFFSET_DARK],
		[ID_DARK_GRASS, ID_MEDIUM_GRASS, X_OFFSET_MEDIUM],
		[ID_MEDIUM_GRASS, ID_LIGHT_GRASS, X_OFFSET_LIGHT]
	]
	
	for t in transitions:
		var low: int = t[0]
		var high: int = t[1]
		var x_offset: int = t[2]
		
		for b in range(16):
			var c0 := high if (b & 8) else low
			var c1 := high if (b & 4) else low
			var c2 := high if (b & 2) else low
			var c3 := high if (b & 1) else low
			
			var base4_index := (c0 * 64) + (c1 * 16) + (c2 * 4) + c3
			var local_tile := template_4x4[b]
			
			arr[base4_index] = Vector2i(x_offset + local_tile.x, local_tile.y)
			
	return arr
