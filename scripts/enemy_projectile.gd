extends Node2D
class_name EnemyProjectile

@onready var sprite: AnimatedSprite2D = $Sprite2D

var direction: Vector2 = Vector2.ZERO

var speed: float = 50
var accel: float = 100
var max_speed = 200

var damage: float = 1

static func instantiate() -> EnemyProjectile:
	return preload("res://scenes/enemy_projectile.tscn").instantiate() as EnemyProjectile

func _physics_process(delta):
	global_position += direction * speed * delta
	
	if speed < max_speed:
		speed += accel * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
