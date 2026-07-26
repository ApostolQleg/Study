extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fade_rect: ColorRect = $FadeRect
@onready var loading_screen: Control = $LoadingScreen

var _next_scene_path: String = ""

func _ready() -> void:
	fade_rect.hide()
	loading_screen.hide()
	set_process(false)

func fast_transition(target_scene: Util.Scene) -> void:
	_next_scene_path = Util.SCENE_PATHS[target_scene]
	
	fade_rect.show()
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(_next_scene_path)
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	fade_rect.hide()

func loading_transition(target_scene: Util.Scene) -> void:
	_next_scene_path = Util.SCENE_PATHS[target_scene]
	
	fade_rect.show()
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	loading_screen.show()
	
	ResourceLoader.load_threaded_request(_next_scene_path)
	
	set_process(true)

func _process(_delta: float) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_next_scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		
		var new_scene = ResourceLoader.load_threaded_get(_next_scene_path)
		get_tree().change_scene_to_packed(new_scene)
		
		loading_screen.hide()
		animation_player.play("fade_out")
		await animation_player.animation_finished
		fade_rect.hide()
