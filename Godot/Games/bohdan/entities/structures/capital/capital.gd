class_name Capital
extends BaseBuilding

func _update_visuals() -> void:
	super()
	
	if roof_sprite:
		roof_sprite.visible = true
		
		if current_faction == Util.Faction.NEUTRAL:
			roof_sprite.frame_coords.y = 0
		else:
			roof_sprite.frame_coords.y = current_faction - 1
