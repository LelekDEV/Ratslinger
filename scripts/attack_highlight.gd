extends Node2D
class_name AttackHighlight

static func instantiate() -> AttackHighlight:
	return preload("res://scenes/attack_highlight.tscn").instantiate() as AttackHighlight

@export var color: Color

var target: Vector2
var alpha: float = 1
var width: float = 10

var arc_mode: bool = false
var arc_spread: float

var decay_tween: Tween
var alternate_tween: Tween

func _physics_process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if arc_mode:
		var target_angle: float = get_angle_to(target) - deg_to_rad(4.25)
		var spread_angle: float = deg_to_rad(arc_spread)
		
		draw_polygon([Vector2.ZERO, 
			Vector2(cos(target_angle - spread_angle), sin(target_angle - spread_angle)) * 400,
			Vector2(cos(target_angle + spread_angle), sin(target_angle + spread_angle)) * 400], 
			[Color(color.r, color.b, color.b, color.a * alpha)])
	else:
		draw_line(Vector2.ZERO, target, Color(color.r, color.b, color.b, color.a * alpha), width)

func start_decay_tween() -> void:
	decay_tween = create_tween() \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN_OUT)
	
	decay_tween.tween_property(self, "alpha", 0, 1.5)
	decay_tween.tween_callback(self.queue_free)

func start_alternate_tween() -> void:
	alternate_tween = create_tween() \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	for i in range(3):
		alternate_tween.tween_callback(GlobalAudio.play_sfx.bind(AudioConsts.SFX.DANGER, -4))
		alternate_tween.tween_property(self, "alpha", 1, 0.1)
		alternate_tween.tween_property(self, "alpha", 0.0 if i == 2 else 0.5, 0.1)
