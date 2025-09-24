#@tool # <-- enable for in-editor preview
extends Node2D

@onready var image: Image = preload("res://graphics/heart_texture.png").get_image()

var anim: float = 0
var anim_speed: float = 5

var width: int = 50
var wave_height: int = 3

var y_top: float = 0
var y_bottom: float = 30

var pixel_size: int = 1

func _physics_process(delta: float) -> void:
	anim += delta * anim_speed
	queue_redraw()

func _draw() -> void:
	for x in range(width):
		var y1: int = int(sin(x * 0.2 + anim) * wave_height) + int(y_top)
		
		for y2 in range(y_bottom - y1):
			var y: int = y1 + y2
			var color: Color = image.get_pixel(x, y + wave_height)
			
			draw_rect(Rect2(x * pixel_size, y * pixel_size, pixel_size, 1 * pixel_size), color)
