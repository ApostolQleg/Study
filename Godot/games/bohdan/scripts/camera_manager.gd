extends Node2D

@export var zoom_speed := 0.05
@export var min_zoom := 0.1
@export var max_zoom := 5.0
@export var drag_speed := 1.0

@export var world_bounds := Rect2(-2000, -1500, 4000, 3000)

var is_pressed := false
var e := Vector2.ZERO

@onready var camera: Camera2D = %Camera2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_pressed:
		e = (event.relative * drag_speed) / camera.zoom.x
		camera.global_position -= e
		clamp_camera_position()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT || event.button_index == MOUSE_BUTTON_MIDDLE:
			is_pressed = event.pressed
			
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_zoom(1.0 + zoom_speed)
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_zoom(1.0 / (1.0 + zoom_speed))

func change_zoom(factor: float) -> void:
	var mouse_screen_pos = get_viewport().get_mouse_position()
	var screen_center = get_viewport().get_visible_rect().size / 2.0
	var screen_offset = mouse_screen_pos - screen_center
	
	var old_zoom = camera.zoom.x
	var target_zoom = old_zoom * factor
	
	var viewport_size = get_viewport().get_visible_rect().size
	
	var absolute_min_zoom_x = viewport_size.x / world_bounds.size.x
	var absolute_min_zoom_y = viewport_size.y / world_bounds.size.y
	
	var safety_min_zoom = max(absolute_min_zoom_x, absolute_min_zoom_y)
	
	var final_min_zoom = max(min_zoom, safety_min_zoom)
	var clamped_zoom = clamp(target_zoom, final_min_zoom, max_zoom)
	
	var world_offset_before = screen_offset / old_zoom
	var world_offset_after = screen_offset / clamped_zoom
	
	camera.zoom = Vector2.ONE * clamped_zoom
	
	camera.global_position += world_offset_before - world_offset_after
	
	clamp_camera_position()

func clamp_camera_position() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var world_view_size = viewport_size / camera.zoom.x
	
	var half_view_x = world_view_size.x / 2.0
	var half_view_y = world_view_size.y / 2.0
	
	var min_x = world_bounds.position.x + half_view_x
	var max_x = world_bounds.end.x - half_view_x
	
	var min_y = world_bounds.position.y + half_view_y
	var max_y = world_bounds.end.y - half_view_y
	
	camera.global_position.x = clamp(camera.global_position.x, min_x, max_x)
	camera.global_position.y = clamp(camera.global_position.y, min_y, max_y)
