extends CanvasLayer

func _ready() -> void:
	Input.set_deferred("mouse_mode", Input.MOUSE_MODE_VISIBLE)

func exit() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Global.resume_game()

func _on_button_pressed() -> void:
	exit()
