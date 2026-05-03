extends Label

@export var rect_offset: Vector2

var progress: float = -1

func _physics_process(delta: float) -> void:
	if Global.game.is_boss_active:
		visible_characters = lerp(len(text), 0, progress)
		progress = min(progress + delta, 1)
		
	elif ":" in text and Global.game.is_wave_active:
		visible_characters = lerp(len(text), text.split(":")[-1].length(), progress)
		progress = min(progress + delta, 1)
		
		if Rect2(get_rect().position + rect_offset, get_rect().size).has_point(get_local_mouse_position()):
			progress = -1
	
	else:
		visible_characters = -1
		progress = -1
