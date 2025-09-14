extends Node

enum ID {SHOOT, BLOOD}

func instantiate(id: ID) -> CPUParticles2D:
	match id:
		ID.SHOOT: return preload("res://scenes/particles/shoot_particles.tscn").instantiate()
		ID.BLOOD: return preload("res://scenes/particles/blood_particles.tscn").instantiate()
	
	return null
