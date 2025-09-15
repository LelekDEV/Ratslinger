extends Area2D
class_name Projectile

var damage: float = 1
var knockback: float = 150

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

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(1)
		body.spawn_damage_particle(global_position)
		body.hit_flash()
		
		body.velocity += direction * knockback
		
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectile"):
		queue_free()
		area.queue_free()
