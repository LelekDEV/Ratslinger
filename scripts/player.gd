extends CharacterBody2D

@onready var gun_sprite: Sprite2D = $GunSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var leg_sprite: AnimatedSprite2D = $LegSprite

var speed: float = 75
var acceleration: float = 0.05

var input: Vector2

var anim: float = 0

func _physics_process(_delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down")
	
	leg_sprite.play("walk" if input.length() > 0 else "idle")
	
	if get_global_mouse_position().x > global_position.x:
		gun_sprite.flip_v = false
		base_sprite.flip_h = false
		leg_sprite.flip_h = false
	else:
		gun_sprite.flip_v = true
		base_sprite.flip_h = true
		leg_sprite.flip_h = true
	
	if base_sprite.frame == 2:
		gun_sprite.position.y = 4.5
	else:
		gun_sprite.position.y = 3.5
	
	gun_sprite.global_rotation = get_angle_to(get_global_mouse_position())
	
	velocity = lerp(velocity, input * speed, acceleration)
	
	move_and_slide()
