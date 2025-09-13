extends Area2D
class_name Projectile

var speed: float = 150
var direction: Vector2
var velocity: Vector2

static func instantiate() -> Projectile:
	return preload("res://scenes/projectile.tscn").instantiate() as Projectile

func _physics_process(delta: float) -> void:
	velocity = direction * speed * delta
	global_position += velocity

func _on_death_timer_timeout() -> void:
	queue_free()
