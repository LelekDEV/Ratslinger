extends Sprite2D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func on_player_shoot() -> void:
	animation.stop()
	animation.play("blink")
