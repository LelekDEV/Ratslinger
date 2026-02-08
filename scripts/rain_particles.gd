extends GPUParticles2D

func _physics_process(_delta: float) -> void:
	amount_ratio = Global.get_rain_change_ratio()
	emitting = amount_ratio > 0
