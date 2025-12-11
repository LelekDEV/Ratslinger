extends Sprite2D

@onready var animation: AnimationPlayer = $AnimationPlayer

@export var scale_factor: float = 1
var origin_scale: float = 4

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	scale = Vector2.ONE * origin_scale * scale_factor

func on_player_shoot(_miss: bool = false) -> void:
	animation.stop()
	animation.play("blink")
