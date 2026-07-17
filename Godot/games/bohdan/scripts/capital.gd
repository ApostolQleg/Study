@tool
class_name Capital
extends BaseBuilding

@export var animation_speed_fps: float = 6.0

@onready var roof_sprite: Sprite2D = $Roof

var _animation_time: float = 0.0
var _anim_direction: int = 1
const TOTAL_FRAMES_PER_ROOF: int = 3

func _process(delta: float) -> void:
	if roof_sprite and roof_sprite.visible:
		_animate_roof(delta)

func _update_visuals() -> void:
	super()
	
	if not is_inside_tree() or not roof_sprite:
		return
		
	if current_faction == Faction.NEUTRAL:
		roof_sprite.visible = false
	else:
		roof_sprite.visible = true
		roof_sprite.frame_coords.y = current_faction - 1

func _animate_roof(delta: float) -> void:
	_animation_time += delta
	var frame_duration = 1.0 / animation_speed_fps
	
	if _animation_time >= frame_duration:
		_animation_time = 0.0
		var current_frame = roof_sprite.frame_coords.x
		var next_frame = current_frame + _anim_direction
		
		if next_frame >= TOTAL_FRAMES_PER_ROOF:
			_anim_direction = -1
			next_frame = current_frame + _anim_direction
		elif next_frame < 0:
			_anim_direction = 1
			next_frame = current_frame + _anim_direction
			
		roof_sprite.frame_coords.x = next_frame
