extends Node

enum ID {SHOOT, BLOOD, BLOCK, HEAL}

func instantiate(id: ID) -> CPUParticles2D:
	match id:
		ID.SHOOT: return preload("res://scenes/fx/particles/shoot_particles.tscn").instantiate()
		ID.BLOOD: return preload("res://scenes/fx/particles/blood_particles.tscn").instantiate()
		ID.BLOCK: return preload("res://scenes/fx/particles/block_particles.tscn").instantiate()
		ID.HEAL: return preload("res://scenes/fx/particles/heal_particles.tscn").instantiate()
	
	return null
