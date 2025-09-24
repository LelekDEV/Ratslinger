extends Control

@onready var wave_draw: Node2D = $MaskSprite/WaveDraw

var target_fill: float = 1
var fill: float = 1

func _physics_process(_delta: float) -> void:
	fill = lerpf(fill, target_fill, 0.05)
	wave_draw.y_top = 33 * (1 - fill)
