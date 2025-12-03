extends Label
class_name AccuracyFX

var type: int = 2

static func instantiate() -> AccuracyFX:
	return preload("res://scenes/accuracy_fx.tscn").instantiate() as AccuracyFX

var anim_tween: Tween

func _ready() -> void:
	var dist: float = 0
	
	match type:
		0:
			text = "miss"
			dist = 10
			add_theme_color_override("font_color", lerp(Color("cc3d3d"), Color.WHITE, 0.65))
			
		1:
			text = "alright"
			dist = 10
			add_theme_color_override("font_color", lerp(Color("d9a756"), Color.WHITE, 0.65))
			
		2:
			text = "perfect"
			dist = 20
			add_theme_color_override("font_color", lerp(Color("59bc76"), Color.WHITE, 0.65))
	
	anim_tween = create_tween().set_parallel()
	
	anim_tween.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR) \
		.tween_property(self, "self_modulate:a", 0, 1)
	
	anim_tween.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO) \
		.tween_property(self, "position", position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * dist, 1)

func _physics_process(_delta: float) -> void:
	if type == 2:
		scale = Vector2.ONE * (abs(sin((1 - self_modulate.a) * PI * 5)) * 0.1 + 1)
