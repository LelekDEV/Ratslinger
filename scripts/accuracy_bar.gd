extends Node2D
class_name AccuracyBar

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var cursor_sprite: Sprite2D = $CursorSprite

var progress_tween: Tween
var progress_value: float = 1
var progress_time: float = 1.5

var started: bool = false

var reload_bullets: bool = false

func _ready() -> void:
	SignalBus.player_shoot.connect(start)

func _physics_process(_delta: float) -> void:
	cursor_sprite.position.x = 0.5 - 85.5 * progress_value
	
	if get_type_from_value(progress_value) != 0 and progress_value != 1 and reload_bullets:
		cursor_sprite.material.set_shader_parameter("is_visible", true)
	else:
		cursor_sprite.material.set_shader_parameter("is_visible", false)

func get_type_from_value(value: float) -> int:
	if value < 0.25 or value > 0.75 and value != 1:
		return 0
	elif value < 0.45 or value > 0.55 and value != 1:
		return 1
	elif value != 1:
		return 2
	
	return 1

func start(_miss: bool = false) -> void:
	if started: return
	started = true
	
	await get_tree().process_frame
	started = false
	
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
	progress_tween.tween_property(self, "progress_value", 1, progress_time)
	
	if reload_bullets:
		progress_tween.tween_callback(player.reload_bullets)
	
	progress_time = 1.5
