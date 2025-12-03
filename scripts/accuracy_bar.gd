extends Node2D
class_name AccuracyBar

@onready var cursor_sprite: Sprite2D = $CursorSprite

var progress_tween: Tween
var progress_value: float = 1

func _ready() -> void:
	SignalBus.player_shoot.connect(start)

func _physics_process(_delta: float) -> void:
	cursor_sprite.position.x = 0.5 - 85.5 * progress_value

func get_type_from_value(value: float) -> int:
	if value < 0.25 or value > 0.75 and value != 1:
		return 0
	elif value < 0.45 or value > 0.55 and value != 1:
		return 1
	elif value != 1:
		return 2
	
	return 1

func start(_miss: bool = false) -> void:
	if progress_tween:
		if progress_tween.is_running():
			var fx: AccuracyFX = AccuracyFX.instantiate()
			
			fx.type = get_type_from_value(progress_value)
			
			fx.position.x = cursor_sprite.position.x - 20
			fx.position.y = 16
			
			add_child(fx)
		
		progress_tween.kill()
	
	progress_value = 0
	
	progress_tween = create_tween()
	progress_tween.tween_property(self, "progress_value", 1, 1.5)
