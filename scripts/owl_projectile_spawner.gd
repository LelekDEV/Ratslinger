extends Node2D
class_name OwlProjectileSpawner

static func instantiate() -> OwlProjectileSpawner:
	return preload("res://scenes/enemies/spawners/owl_projectile_spawner.tscn").instantiate() as OwlProjectileSpawner

@onready var projectiles: Node2D = get_tree().get_first_node_in_group("projectiles")
@onready var fx: Node2D = get_tree().get_first_node_in_group("fx")

@onready var sprite: Sprite2D = $Sprite2D

var parent: Enemy

var spin_tween: Tween
var spin_value: float = 0
var spin_shots: Array = []
var spin_notions: Array = []

func _ready() -> void:
	var start: float = randf_range(0.5, 0.6)
	
	for i in range(3):
		spin_shots.append(start + 0.2 * 2/3.0 * i)
		spin_notions.append(spin_shots[-1] - 0.4)

func _physics_process(_delta: float) -> void:
	global_rotation = TAU * 5 * spin_value
	
	for v in spin_shots:
		if spin_value >= v:
			GlobalAudio.play_sfx(AudioConsts.SFX.ENEMY_SHOOT, -6)
			spawn_projectile()
			
			spin_shots.erase(v)
	
	for v in spin_notions:
		if spin_value >= v:
			var highlight := AttackHighlight.instantiate()
			highlight.global_position = global_position
			highlight.target = Vector2.RIGHT.rotated(TAU * 5 * v) * 400
			highlight.start_alternate_tween(false)
			fx.add_child(highlight)
			
			spin_notions.erase(v) 
	
	var shader_value: float = max(spin_value - 0.9, 0)
	sprite.material.set_shader_parameter("progress_scatter", shader_value * 60)
	sprite.material.set_shader_parameter("progress_rotation", shader_value * 100)
	sprite.material.set_shader_parameter("progress_fade", shader_value * 10)

func spin_start() -> void:
	await get_tree().create_timer(0.6).timeout
	
	spin_tween = create_tween() \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN)
	
	spin_tween.tween_property(self, "spin_value", 1, 2)
	spin_tween.tween_callback(queue_free)

func spawn_projectile() -> void:
	var shoot_dir = Vector2.RIGHT.rotated(global_rotation)
	var shoot_pos = shoot_dir * 6
	
	var projectile = EnemyProjectile.instantiate("fox")
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT)
	
	projectile.global_position = global_position + shoot_pos
	projectile.global_rotation = shoot_dir.angle()
	projectile.direction = shoot_dir
	
	projectile.damage = 1
	if parent: projectile.parent = parent
	
	particles.global_position = global_position + shoot_pos
	particles.global_rotation = shoot_dir.angle()
	particles.emitting = true  
	  
	projectiles.add_child(projectile)
	fx.add_child(particles)
