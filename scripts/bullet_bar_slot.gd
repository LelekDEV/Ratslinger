extends Control
class_name BulletBarSlot

@onready var sprite: Sprite2D = $Sprite2D

var anim: float = 0

var anim_tween: Tween
var anim_value: float = 0

func _physics_process(delta: float) -> void:
	if sprite.frame_coords.y == 2:
		anim = fmod(anim + 10 * delta, 11)
		sprite.frame_coords.x = int(anim)
	
	elif sprite.frame_coords.y == 4:
		anim = fmod(anim + 10 * delta, 6)
		sprite.frame_coords.x = int(anim)
	
	else:
		sprite.frame_coords.x = 0
