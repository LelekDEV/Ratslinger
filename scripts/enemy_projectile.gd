extends Node2D
class_name FoxBullet

@onready var sprite: AnimatedSprite2D = $Sprite2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 50
var accel: float = 100
var max_speed = 200

func _ready():
	sprite.play("shoot")

func _physics_process(delta):
	global_position += direction * speed * delta
	if speed < max_speed:
		speed += accel * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
