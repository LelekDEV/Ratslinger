#@tool # <-- enable for in-editor preview
extends Node2D

var anim: float = 0
var anim_speed: float = 5

var width: int = 50
var height: int = 3

var pixel_size: int = 1

func _physics_process(delta: float) -> void:
	anim += delta * anim_speed
	queue_redraw()

func _draw() -> void:
	for x in range(width):
		var y: int = int(sin(x * 0.2 + anim) * height)
		draw_rect(Rect2(x * pixel_size, y * pixel_size, pixel_size, (height - y) * pixel_size), "#e55c5c")
