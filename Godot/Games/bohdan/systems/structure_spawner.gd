class_name StructureSpawner
extends Node

@export_group("City Group")
@export var capital_scene: PackedScene
@export var city_scene: PackedScene
@export var altar_scene: PackedScene
@export var store_scene: PackedScene

@export_group("Tower Group")
@export var tower_scene: PackedScene
@export var tower_spawn_chance: float = 0.5

@export_group("Loot Group")
@export var chest_scene: PackedScene
@export var min_chests: int = 10
@export var max_chests: int = 20

@onready var entity_root: Node2D = %EntityRoot

var occupied_cells: Dictionary = {}
var map_gen: MapGenerator

func _ready() -> void:
	map_gen = Global.map_generator
	
	if map_gen:
		map_gen.terrain_ready.connect(_on_terrain_ready)
		print("Map generator found, %s" % map_gen)
	else:
		print("Map generator not found, found %s" % map_gen)

func _on_terrain_ready(grid: Dictionary) -> void:
	occupied_cells.clear()
	_clear_existing_entities()
	
	_spawn_capitals(grid)
	_spawn_first_group(grid)
	_spawn_towers(grid)
	_spawn_chests(grid)
	
	print("Structures spawned!")

func _clear_existing_entities() -> void:
	if not entity_root: 
		print("Entity root not found")
		return
	for child in entity_root.get_children():
		child.queue_free()

func _spawn_capitals(grid: Dictionary) -> void:
	pass

func _spawn_first_group(grid: Dictionary) -> void:
	pass

func _spawn_towers(grid: Dictionary) -> void:
	pass

func _spawn_chests(grid: Dictionary) -> void:
	pass
