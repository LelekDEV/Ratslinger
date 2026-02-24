extends Area2D
class_name Coin

static func instantiate() -> Coin:
	return preload("res://scenes/coin.tscn").instantiate() as Coin

@onready var bound_rect: ReferenceRect = get_tree().get_first_node_in_group("coin_bound_rect")

var target_player: Player

var lerp_tween: Tween
var lerp_value: float = 0.01

var velocity: Vector2

var arc_tween: Tween
var arc_value: float

var circle_center: Vector2
var circle_radius: float
var circle_rot: float
var mult_y: float = 1

enum Modes {MAGNET, ARC}
var mode: Modes = Modes.MAGNET

func _ready() -> void:
	if mode != Modes.ARC:
		if not bound_rect.get_rect().has_point(global_position):
			collect()
		
		return
	
	arc_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_SINE)
	
	arc_tween.tween_property(self, "arc_value", 1, 0.5)
	arc_tween.tween_callback(collect)

func _physics_process(_delta: float) -> void:
	if mode == Modes.ARC:
		var v: float = arc_value * PI + PI
		var r: float = circle_rot
		var a: float = circle_radius
		var b: float = circle_radius * mult_y
		
		global_position = circle_center + Vector2(
			a * cos(v) * cos(r) - b * sin(v) * sin(r),
			a * cos(v) * sin(r) + b * sin(v) * cos(r)
		)
	
	elif mode == Modes.MAGNET:
		if target_player:
			global_position = Global.fixed_lerp(global_position, target_player.global_position, lerp_value)
			
			if round(global_position) == round(target_player.global_position):
				collect()
		else:
			global_position += velocity
			velocity = Global.fixed_lerp(velocity, Vector2.ZERO, 0.05)

func collect() -> void:
	GlobalAudio.play_sfx(AudioConsts.SFX.COLLECT, -2, randf_range(0.9, 1.1))
	Global.coins += 1
	SignalBus.player_coin_collect.emit()
	
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body
		
		lerp_tween = create_tween()
		lerp_tween.tween_property(self, "lerp_value", 1, 1)
