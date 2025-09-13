extends CPUParticles2D
class_name ShootParticles

static func instantiate() -> ShootParticles:
	return preload("res://scenes/shoot_particles.tscn").instantiate() as ShootParticles

func _on_finished() -> void:
	queue_free()
