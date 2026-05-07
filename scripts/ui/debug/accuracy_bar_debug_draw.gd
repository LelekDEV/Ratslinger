extends Node2D

@export var parent: AccuracyBar
@onready var tresholds: Array = parent.accuracy_tresholds

const rect_size := Vector2(77, 15)
const colors: Array = [Color.RED, Color.YELLOW, Color.GREEN]

func _draw() -> void:
	var last_v: float = 0
	for treshold in tresholds:
		var x: float = last_v * rect_size.x
		
		draw_rect(Rect2(
			Vector2(x, 0), 
			Vector2(treshold.v * rect_size.x - x, rect_size.y)
		), colors[treshold.t])
		
		last_v = treshold.v
