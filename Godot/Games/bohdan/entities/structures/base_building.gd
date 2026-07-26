class_name BaseBuilding
extends Node2D

@export var current_faction: Util.Faction = Util.Faction.NEUTRAL:
	set(value):
		current_faction = value
		_update_visuals()

@export_group("Roof Animation")
@export var animation_speed_fps: float = 6.0
@export var total_frames_per_roof: int = 3

@onready var base_sprite: Sprite2D = get_node_or_null("Base")
@onready var faction_symbol: Sprite2D = get_node_or_null("Faction")
@onready var roof_sprite: Sprite2D = get_node_or_null("Roof")

var _animation_time: float = 0.0
var _anim_direction: int = 1

func _ready() -> void:
	_update_visuals()

func _process(delta: float) -> void:
	if roof_sprite and roof_sprite.visible and total_frames_per_roof > 1:
		_animate_roof(delta)

func _update_visuals() -> void:
	if not is_inside_tree():
		return
		
	if faction_symbol:
		faction_symbol.visible = current_faction != Util.Faction.NEUTRAL
		if faction_symbol.visible and (faction_symbol.hframes * faction_symbol.vframes > 1):
			faction_symbol.frame = current_faction - 1
			
	if base_sprite:
		base_sprite.visible = true 
		if base_sprite.hframes * base_sprite.vframes > 1:
			if current_faction == Util.Faction.NEUTRAL:
				base_sprite.frame = 0
			else:
				base_sprite.frame = current_faction - 1

func _animate_roof(delta: float) -> void:
	_animation_time += delta
	if _animation_time >= 1.0 / animation_speed_fps:
		_animation_time = 0.0
		var next_frame = roof_sprite.frame_coords.x + _anim_direction
		if next_frame >= total_frames_per_roof or next_frame < 0:
			_anim_direction *= -1
		roof_sprite.frame_coords.x += _anim_direction
