extends Camera2D

var shake_tween: Tween
var shake_value: float = 0

var shake_time: float = 0.2
var shake_intensity: float = 2.5
var shake_smoothness: float = 0.8

@export var gate: StaticBody2D

func _ready() -> void:
	await SignalBus.game_loaded
	
	reset_physics_interpolation()
	reset_smoothing()

func _physics_process(_delta: float) -> void:
	if shake_tween and shake_tween.is_running():
		var target: Vector2 = Vector2.RIGHT.rotated(randf_range(-PI, PI)) * sin(shake_value * PI) * shake_intensity
		offset = lerp(offset, target, 1 - shake_smoothness)
	else:
		offset = Vector2.ZERO
	
	if get_parent().global_position.x > gate.global_position.x:
		global_position.x = max(-324 + get_viewport_rect().size.x / zoom.x / 2, get_parent().global_position.x)
	else:
		global_position = get_parent().global_position

func shake(miss: bool = false) -> void:
	if miss:
		return
	
	shake_tween = create_tween()
	
	shake_value = 0
	shake_tween.tween_property(self, "shake_value", 1, shake_time)
