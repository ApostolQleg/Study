class_name Tower
extends BaseBuilding

func _update_visuals() -> void:
	super()
	
	if roof_sprite:
		roof_sprite.visible = true
		roof_sprite.frame_coords.y = 0
