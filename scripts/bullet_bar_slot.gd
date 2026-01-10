extends Control

@onready var sprite: Sprite2D = $Sprite2D

var anim: float = 0

func _physics_process(delta: float) -> void:
	if sprite.frame_coords.y == 2:
		anim = fmod(anim + 10 * delta, 11)
		sprite.frame_coords.x = int(anim)
	else:
		sprite.frame_coords.x = 0
