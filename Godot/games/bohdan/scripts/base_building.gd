class_name BaseBuilding
extends Node2D

enum Faction { 
	NEUTRAL,
	KING,
	CHRIST,
	DRUID,
	SATAN
}

@export var current_faction: Faction = Faction.NEUTRAL:
	set(value):
		current_faction = value
		_update_visuals()

@onready var base_sprite: Sprite2D = get_node_or_null("Base")
@onready var faction_symbol: Sprite2D = get_node_or_null("Faction")

func _ready() -> void:
	_update_visuals()

func _update_visuals() -> void:
	if not is_inside_tree():
		return
		
	if faction_symbol:
		if current_faction == Faction.NEUTRAL:
			faction_symbol.visible = false
		else:
			faction_symbol.visible = true
			faction_symbol.frame = current_faction - 1
			
	elif base_sprite:
		if current_faction == Faction.NEUTRAL:
			base_sprite.visible = false
		else:
			base_sprite.visible = true
			base_sprite.frame = current_faction - 1
