extends Node

var fullscreen_enabled: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		fullscreen_enabled = not fullscreen_enabled
		
		if fullscreen_enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
