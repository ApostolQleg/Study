extends Control

func _on_start_button_pressed() -> void:
	SceneManager.loading_transition(Util.Scene.GAME)

func _on_options_button_pressed() -> void:
	print("Options pressed!")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
