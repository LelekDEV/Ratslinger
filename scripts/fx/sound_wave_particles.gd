extends CPUParticles2D

@onready var single_note_particles: CPUParticles2D = get_child(0)

func _ready() -> void:
	single_note_particles.emitting = true

func _on_finished() -> void:
	queue_free()
	single_note_particles.queue_free()
