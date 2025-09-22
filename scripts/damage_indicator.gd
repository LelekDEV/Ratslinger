extends Label

@onready var animation: AnimationPlayer = $AnimationPlayer

var tween: Tween

var is_critical: bool

func _ready() -> void:
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "position", position - Vector2(0, 20), 1)
	
	animation.play("critical" if is_critical else "regular")
