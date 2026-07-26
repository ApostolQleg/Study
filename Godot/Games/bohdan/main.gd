extends Node

@onready var map_generator: MapGenerator = $World/WorldRoot/MapGenerator
@onready var camera_manager: Node2D = %CameraManager

func _ready() -> void:
	map_generator.world_generated.connect(_on_world_generated)
	map_generator.generate_new_map()

func _on_world_generated(bounds: Rect2) -> void:
	camera_manager.update_world_bounds(bounds)
