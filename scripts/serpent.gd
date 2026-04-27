extends Node2D
class_name Serpent

static func instantiate() -> Serpent:
	return preload("res://scenes/serpent.tscn").instantiate() as Serpent

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var projectiles: Node2D = get_tree().get_first_node_in_group("projectiles")

@onready var body: Node2D = $SubViewport/SerpentBody
@onready var face_sprite: Sprite2D = $FaceSprite

func _ready() -> void:
	await get_tree().create_timer(0.1, false).timeout
	visible = true

func _physics_process(_delta: float) -> void:
	for point: Vector2 in body.points:
		if point.distance_squared_to(player.global_position) <= 200:
			player.enter_squeeze()
			
			GlobalAudio.play_sfx(AudioConsts.SFX.HISS_SOFT, 2, 1, -1)
			
			queue_free()
			return
	
		for projectile in projectiles.get_children():
			if projectile is Projectile:
				if point.distance_squared_to(projectile.global_position) <= 100:
					var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOOD)
					particles.global_position = projectile.global_position
					particles.emitting = true
					get_tree().root.add_child(particles)
					
					GlobalAudio.play_sfx(AudioConsts.SFX.HISS, -10, 1.2)
					
					projectile.queue_free()
					queue_free()
					return
	
	face_sprite.global_rotation = body.dir.angle() - PI / 2
