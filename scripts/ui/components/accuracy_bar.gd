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

# I'm not sure whether consts would be better as snake_case or SCREAMING_SNAKE_CASE.
# I'll just leave it there
const accuracy_tresholds: Array = [
	{"v": 0.25, "t": 0},
	{"v": 0.45, "t": 1},
	{"v": 0.55, "t": 2},
	{"v": 0.75, "t": 1},
	{"v": 1.0, "t": 0}
]

var first_perfect_value: float

func _ready() -> void:
	SignalBus.player_shoot.connect(start)
	
	for i in range(accuracy_tresholds.size()):
		if accuracy_tresholds[i].t == 2:
			first_perfect_value = accuracy_tresholds[i - 1].v
			return

func _physics_process(_delta: float) -> void:
	cursor_sprite.position.x = 0.5 - 85.5 * progress_value
	
	if get_type_from_value(progress_value) != 0 and progress_value != 1 and reload_bullets:
		cursor_sprite.material.set_shader_parameter("is_visible", true)
	else:
		cursor_sprite.material.set_shader_parameter("is_visible", false)

func get_type_from_value(value: float) -> int:
	if value == 1:
		return 1
	
	for i in range(accuracy_tresholds.size() - 2, -1, -1):
		if value > accuracy_tresholds[i].v:
			return accuracy_tresholds[i + 1].t
	
	return accuracy_tresholds[0].t

func accuracy_signal() -> void:
	const EARLY_OFFSET: float = 0.08
	
	await get_tree().create_timer(first_perfect_value * progress_time - EARLY_OFFSET, false).timeout
	
	if get_type_from_value(progress_value + EARLY_OFFSET * progress_time) != 2:
		return
	
	SignalBus.accuracy_perfect_early.emit()
	
	await get_tree().create_timer(EARLY_OFFSET, false).timeout
	SignalBus.accuracy_perfect_entered.emit()

func start(_miss: bool = false) -> void:
	if started: return
	started = true
	
	await get_tree().physics_frame
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
