extends Node2D

const TILE_SIZE: int = 16

@onready var ray_cast: RayCast2D = $RayCast
@onready var sprite: Sprite2D = $Sprite

var autotiler: DualGridAutotiler

func _ready() -> void:
	autotiler = get_tree().current_scene.find_child("DualGridAutotiler") as DualGridAutotiler
	position = position.snapped(Vector2.ONE * TILE_SIZE) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)

func _unhandled_input(event: InputEvent) -> void:
	var direction := Vector2.ZERO
	
	if event is InputEventKey and event.pressed and not event.is_echo():
		match event.physical_keycode:
			KEY_W: direction = Vector2.UP
			KEY_S: direction = Vector2.DOWN
			KEY_A: direction = Vector2.LEFT
			KEY_D: direction = Vector2.RIGHT
			
	if direction != Vector2.ZERO:
		_try_move(direction)

func _try_move(direction: Vector2) -> void:
	var target_pos = position + (direction * TILE_SIZE)
	
	ray_cast.target_position = direction * TILE_SIZE
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		return
		
	if autotiler:
		var target_cell = autotiler.local_to_map(target_pos)
		var terrain_id = autotiler._get_terrain_at(target_cell)
		
		if terrain_id == autotiler.ID_WATER:
			return
			
	position = target_pos
