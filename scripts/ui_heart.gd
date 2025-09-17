extends Control

@onready var wave_draw: Node2D = $MaskSprite/WaveDraw
@onready var color_rect: ColorRect = $MaskSprite/ColorRect

var target_fill: float = 1
var fill: float = 1

func _physics_process(_delta: float) -> void:
	fill = lerpf(fill, target_fill, 0.05)
	
	wave_draw.position.y = -11 + 32 * (1 - fill)
	color_rect.position.y = -9 + 32 * (1 - fill)
