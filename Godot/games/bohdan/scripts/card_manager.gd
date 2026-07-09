extends Node2D

const COLLISION_MASK_CARD = 1
const CARD_SCALE_HOVERED_OFF = 1
const CARD_SCALE_HOVERED = 1.2
const CARD_SCALE_DRAGGED = 1.1

var screen_size
var card_dragged
var is_hovering_on_card

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	if card_dragged:
		var mouse_pos = get_global_mouse_position()
		card_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x), 
			clamp(mouse_pos.y, 0, screen_size.y)
		)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = check_for_card()
			if card:
				start_drag(card)
		else:
			finish_drag() 

func start_drag(card):
	card_dragged = card
	card_dragged.z_index = 10 
	card_dragged.scale = Vector2(CARD_SCALE_DRAGGED, CARD_SCALE_DRAGGED)

func finish_drag():
	if !card_dragged:
		return
		
	var card_under_mouse = check_for_card()
	if card_under_mouse == card_dragged:
		card_dragged.scale = Vector2(CARD_SCALE_HOVERED, CARD_SCALE_HOVERED)
		card_dragged.z_index = 2
	else:
		card_dragged.scale = Vector2(CARD_SCALE_HOVERED_OFF, CARD_SCALE_HOVERED_OFF)
		card_dragged.z_index = 1
		is_hovering_on_card = false
		
	card_dragged = null

func connect_card_signals(card):
	card.connect("hovered", on_hovered_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_card(card):
	if card_dragged:
		return
		
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !card_dragged:
		highlight_card(card, false)
		var new_card_hovered = check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_SCALE_HOVERED,CARD_SCALE_HOVERED)
		card.z_index = 2
	else:
		card.scale = Vector2(CARD_SCALE_HOVERED_OFF, CARD_SCALE_HOVERED_OFF)
		card.z_index = 1

func check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD 
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card
