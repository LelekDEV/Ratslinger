extends Node2D

var target: Vector2
var color: Color = "#ff262641"
var alpha: float = 1

func _physics_process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	draw_line(Vector2.ZERO, target, Color(color.r, color.b, color.b, color.a * alpha), 10)
