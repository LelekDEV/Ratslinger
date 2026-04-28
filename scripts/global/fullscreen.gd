extends Node

@onready var transition_rect: ColorRect = get_tree().get_first_node_in_group("fullscreen_transition_rect")

var fullscreen_enabled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		fullscreen_enabled = not fullscreen_enabled
		
		if fullscreen_enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		transition_rect.visible = true
		await get_tree().process_frame
		transition_rect.visible = false
