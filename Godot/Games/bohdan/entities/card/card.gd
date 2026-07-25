extends Control

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
		
@onready var base_rect: TextureRect = get_node_or_null("Base")

const CARD_X_REGION := 19
const CARD_Y_REGION := 2

func _ready() -> void:
	if base_rect and base_rect.texture is AtlasTexture:
		base_rect.texture = base_rect.texture.duplicate()
		
	_update_visuals()
	
func _update_visuals() -> void:
	if not is_inside_tree() or not base_rect:
		return
			
	var atlas = base_rect.texture as AtlasTexture
	if atlas and atlas.atlas:
		var full_width : int = atlas.atlas.get_width()
		var frame_width := full_width / 5.0
		var frame_height : int = atlas.atlas.get_height()
		var x_region := int(current_faction) * frame_width + CARD_X_REGION
		var y_region := CARD_Y_REGION
		var card_width := frame_width - (CARD_X_REGION * 2)
		var card_height := frame_height - (CARD_Y_REGION * 2)
		
		atlas.region = Rect2(
			x_region,
			y_region,
			card_width,
			card_height
		)
