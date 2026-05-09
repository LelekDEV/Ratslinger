extends Node

enum ID {SHOOT, BLOOD, BLOCK, HEAL, SHOOT_HEAVY, SHOOT_SOUND_WAVE}

func instantiate(id: ID) -> CPUParticles2D:
	match id:
		ID.SHOOT: return preload("res://scenes/fx/particles/shoot_particles.tscn").instantiate()
		ID.BLOOD: return preload("res://scenes/fx/particles/blood_particles.tscn").instantiate()
		ID.BLOCK: return preload("res://scenes/fx/particles/block_particles.tscn").instantiate()
		ID.HEAL: return preload("res://scenes/fx/particles/heal_particles.tscn").instantiate()
		ID.SHOOT_HEAVY: return preload("res://scenes/fx/particles/shoot_heavy_particles.tscn").instantiate()
		ID.SHOOT_SOUND_WAVE: return preload("res://scenes/fx/particles/shoot_sound_wave_particles.tscn").instantiate()
	return null
