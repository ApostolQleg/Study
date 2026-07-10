extends Node2D

const CARD_SCALE_HOVERED_OFF : float = 1.0
const CARD_SCALE_HOVERED : float  = 1.1
const CARD_SCALE_DRAGGED : float = 1.2

var screen_size : Vector2
var card_dragged : Node2D = null
var _drag_offset : Vector2 = Vector2.ZERO
var _card_half_size : Vector2 = Vector2.ZERO

var cards_under_mouse : Array[Node2D] = []

func _ready() -> void:
	screen_size = get_viewport_rect().size

func get_canvas_mouse_pos() -> Vector2:
	return get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

func _process(_delta: float) -> void:
	if card_dragged:
		var target_pos : Vector2 = get_canvas_mouse_pos() + _drag_offset
		
		card_dragged.global_position = Vector2(
			clamp(target_pos.x, _card_half_size.x, screen_size.x - _card_half_size.x), 
			clamp(target_pos.y, _card_half_size.y, screen_size.y - _card_half_size.y)
		)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card : Node2D = get_top_hovered_card()
			if card:
				start_drag(card)
		else:
			finish_drag() 

func start_drag(card: Node2D) -> void:
	card_dragged = card
	card_dragged.z_index = 10 
	card_dragged.scale = Vector2(CARD_SCALE_DRAGGED, CARD_SCALE_DRAGGED)
	
	_drag_offset = card.global_position - get_canvas_mouse_pos()
	
	var card_full_size : Vector2 = card_dragged.get_node("Area2D/CollisionShape2D").shape.size
	_card_half_size = (card_full_size * card_dragged.scale) / 2.0

func finish_drag() -> void:
	if not card_dragged:
		return
		
	card_dragged = null
	update_highlight()

func connect_card_signals(card: Node2D) -> void:
	card.connect("hovered", on_hovered_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_card(card: Node2D) -> void:
	if not cards_under_mouse.has(card):
		cards_under_mouse.append(card)
	update_highlight()

func on_hovered_off_card(card: Node2D) -> void:
	if cards_under_mouse.has(card):
		cards_under_mouse.erase(card)
	
	highlight_card(card, false)
	update_highlight()

func update_highlight() -> void:
	if card_dragged:
		return
		
	var top_card : Node2D = get_top_hovered_card()
	
	for card in cards_under_mouse:
		if card != top_card:
			highlight_card(card, false)
			
	if top_card:
		highlight_card(top_card, true)

func highlight_card(card: Node2D, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(CARD_SCALE_HOVERED, CARD_SCALE_HOVERED)
		card.z_index = 2
	else:
		card.scale = Vector2(CARD_SCALE_HOVERED_OFF, CARD_SCALE_HOVERED_OFF)
		card.z_index = 1

func get_top_hovered_card() -> Node2D:
	if cards_under_mouse.is_empty():
		return null
		
	var highest_z_card : Node2D = cards_under_mouse[0]
	var highest_z_index : int = highest_z_card.z_index
	
	for i in range(1, cards_under_mouse.size()):
		var current_card = cards_under_mouse[i]
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card
