extends Node2D

const COLLISION_MASK_CARD : int = 1

const CARD_SCALE_HOVERED_OFF : float = 1.0
const CARD_SCALE_HOVERED : float  = 1.1
const CARD_SCALE_DRAGGED : float = 1.2

var screen_size : Vector2
var card_dragged : Node2D = null
var _drag_offset : Vector2 = Vector2.ZERO
var _card_half_size : Vector2 = Vector2.ZERO
var is_hovering_on_card : bool = false

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if card_dragged:
		var target_pos : Vector2 = get_global_mouse_position() + _drag_offset
		
		card_dragged.position = Vector2(
			clamp(target_pos.x, _card_half_size.x, screen_size.x - _card_half_size.x), 
			clamp(target_pos.y, _card_half_size.y, screen_size.y - _card_half_size.y)
		)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card : Node2D = check_for_card()
			if card:
				start_drag(card)
		else:
			finish_drag() 

func start_drag(card: Node2D) -> void:
	card_dragged = card
	card_dragged.z_index = 10 
	card_dragged.scale = Vector2(CARD_SCALE_DRAGGED, CARD_SCALE_DRAGGED)
	
	_drag_offset = card.global_position - get_global_mouse_position()
	
	var card_full_size : Vector2 = card_dragged.get_node("Area2D/CollisionShape2D").shape.size
	_card_half_size = (card_full_size * card_dragged.scale) / 2.0

func finish_drag() -> void:
	if not card_dragged:
		return
		
	var card_under_mouse : Node2D = check_for_card()
	if card_under_mouse == card_dragged:
		card_dragged.scale = Vector2(CARD_SCALE_HOVERED, CARD_SCALE_HOVERED)
		card_dragged.z_index = 2
	else:
		card_dragged.scale = Vector2(CARD_SCALE_HOVERED_OFF, CARD_SCALE_HOVERED_OFF)
		card_dragged.z_index = 1
		is_hovering_on_card = false
		
	card_dragged = null

func connect_card_signals(card: Node2D) -> void:
	card.connect("hovered", on_hovered_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_card(card: Node2D) -> void:
	if card_dragged:
		return
		
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card: Node2D) -> void:
	if not card_dragged:
		highlight_card(card, false)
		var new_card_hovered : Node2D = check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card: Node2D, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(CARD_SCALE_HOVERED, CARD_SCALE_HOVERED)
		card.z_index = 2
	else:
		card.scale = Vector2(CARD_SCALE_HOVERED_OFF, CARD_SCALE_HOVERED_OFF)
		card.z_index = 1

func check_for_card() -> Node2D:
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters : PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD 
	
	var result : Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards: Array[Dictionary]) -> Node2D:
	var highest_z_card : Node2D = cards[0].collider.get_parent() as Node2D
	var highest_z_index : int = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card : Node2D = cards[i].collider.get_parent() as Node2D
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card
