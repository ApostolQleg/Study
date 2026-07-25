class_name Chest
extends Node2D

enum State { CLOSED = 0, HOVERED = 1, OPENED = 2 }

var current_state: State = State.CLOSED

@onready var base_sprite: Sprite2D = $Base
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	current_state = State.CLOSED
	_update_visuals()
	
	if area_2d:
		area_2d.mouse_entered.connect(_on_mouse_entered)
		area_2d.mouse_exited.connect(_on_mouse_exited)
		area_2d.input_event.connect(_on_input_event)

func _update_visuals() -> void:
	if base_sprite:
		base_sprite.frame = current_state

func _on_mouse_entered() -> void:
	if current_state == State.CLOSED:
		current_state = State.HOVERED
		_update_visuals()

func _on_mouse_exited() -> void:
	if current_state == State.HOVERED:
		current_state = State.CLOSED
		_update_visuals()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_state != State.OPENED and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			open_chest()

func open_chest() -> void:
	current_state = State.OPENED
	_update_visuals()
	
	if area_2d:
		area_2d.input_pickable = false
	
	_spawn_loot()

func _spawn_loot() -> void:
	print("Chest is opened")
