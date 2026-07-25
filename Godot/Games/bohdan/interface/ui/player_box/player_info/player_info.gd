@tool
extends HBoxContainer

@export var is_compact: bool = false:
	set(value):
		is_compact = value
		_update_layout()

@onready var avatar: TextureRect = $Avatar
@onready var nickname: Label = $Nickname

func _ready() -> void:
	_update_layout()

func _update_layout() -> void:
	if not is_node_ready():
		return
		
	if is_compact:
		avatar.custom_minimum_size = Vector2(32, 32)
		nickname.add_theme_font_size_override("font_size", 12) 
		add_theme_constant_override("separation", 6) 
	else:
		avatar.custom_minimum_size = Vector2(48, 48)
		nickname.remove_theme_font_size_override("font_size") 
		remove_theme_constant_override("separation")
