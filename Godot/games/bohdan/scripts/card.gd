extends Node2D

signal hovered
signal hovered_off

func _ready() -> void:
	# All cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	if get_parent().card_dragged == self:
		return
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	if get_parent().card_dragged == self:
		return
	emit_signal("hovered_off", self)
