extends Node2D
class_name AccuracyBar

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var cursor_sprite: Sprite2D = $CursorSprite

var progress_tween: Tween
var progress_value: float = 1
var progress_time: float = 1.5

var anim_tween: Tween
var anim_value: float = 0

var started: bool = false
var reload_bullets: bool = false

var accuracy_tresholds: Array = [0.25, 0.45, 0.55, 0.75]

func _ready() -> void:
	SignalBus.player_shoot.connect(start)

func _physics_process(_delta: float) -> void:
	cursor_sprite.position.x = 0.5 - 85.5 * progress_value
	
	if get_type_from_value(progress_value) != 0 and progress_value != 1 and reload_bullets:
		cursor_sprite.material.set_shader_parameter("is_visible", true)
	else:
		cursor_sprite.material.set_shader_parameter("is_visible", false)

func get_type_from_value(value: float) -> int:
	if value < accuracy_tresholds[0] or value > accuracy_tresholds[3] and value != 1:
		return 0
	elif value < accuracy_tresholds[1] or value > accuracy_tresholds[2] and value != 1:
		return 1
	elif value != 1:
		return 2
	
	return 1

func accuracy_signal() -> void:
	await get_tree().create_timer(accuracy_tresholds[1] * progress_time - 0.1).timeout
	SignalBus.accuracy_perfect_early.emit()
	
	await get_tree().create_timer(0.1).timeout
	SignalBus.accuracy_perfect_entered.emit()

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
	
	progress_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	
	progress_tween.tween_property(self, "progress_value", 1, progress_time)
	
	if reload_bullets and Settings.accuracy_flash_accessibility:
		accuracy_signal()
	
	if reload_bullets:
		progress_tween.tween_callback(player.reload_bullets)
	
	progress_time = 1.5
