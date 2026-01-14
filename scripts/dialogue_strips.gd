extends Node2D

@export var width: float = 0

func _physics_process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, get_viewport_rect().size.x, width), Color.BLACK)
	draw_rect(Rect2(0, get_viewport_rect().size.y - width, get_viewport_rect().size.x, width), Color.BLACK)
