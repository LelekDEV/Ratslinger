extends CPUParticles2D

func _on_finished() -> void:
	queue_free()
