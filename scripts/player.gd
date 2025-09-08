extends CharacterBody2D

@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var gun_sprite: Sprite2D = $GunSprite

var speed: float = 100
var acceleration: float = 0.03

var input: Vector2

var anim: float = 0

func _physics_process(_delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down")
	
	if get_global_mouse_position().x > global_position.x:
		base_sprite.flip_h = false
		gun_sprite.flip_v = false
	else:
		base_sprite.flip_h = true
		gun_sprite.flip_v = true
	
	if base_sprite.frame == 2:
		gun_sprite.position.y = 4.5
	else:
		gun_sprite.position.y = 3.5
	
	gun_sprite.global_rotation = get_angle_to(get_global_mouse_position())
	
	velocity = lerp(velocity, input * speed, acceleration)
	move_and_slide()
