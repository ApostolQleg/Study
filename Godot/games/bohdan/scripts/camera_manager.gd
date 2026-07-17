extends Node2D

@export var zoom_speed := 0.05
@export var min_zoom := 0.1
@export var max_zoom := 5.0
@export var drag_speed := 1.0

var is_pressed := false
var e := Vector2.ZERO

@onready var camera: Camera2D = %Camera2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_pressed:
		e = (event.relative * drag_speed) / camera.zoom.x
		camera.position -= e
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT || event.button_index == MOUSE_BUTTON_MIDDLE:
			is_pressed = event.pressed
			
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var target_zoom = camera.zoom.x * (1.0 + zoom_speed)
			var clamped_zoom = clamp(target_zoom, min_zoom, max_zoom)
			camera.zoom = Vector2.ONE * clamped_zoom
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var target_zoom = camera.zoom.x / (1.0 + zoom_speed)
			var clamped_zoom = clamp(target_zoom, min_zoom, max_zoom)
			camera.zoom = Vector2.ONE * clamped_zoom
