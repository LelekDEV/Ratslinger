extends Area2D
class_name Projectile

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var special_particles: CPUParticles2D = $SpecialParticles

var damage: float = 1
var knockback: float = 150

var speed: float = 150
var direction: Vector2
var velocity: Vector2
var penetrating: bool = false

enum Type {REGULAR = -1, VAMPIRE, FIRE, POISON}
var type: Type = Type.REGULAR

static func instantiate() -> Projectile:
	return preload("res://scenes/projectile.tscn").instantiate() as Projectile

func _ready() -> void:
	if type != Type.REGULAR:
		special_particles.emitting = true
		
		if type == Type.VAMPIRE:
			sprite.self_modulate = Color("d96c8fff")

func _physics_process(delta: float) -> void:
	velocity = direction * speed * delta
	global_position += velocity

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	
	if body.is_in_group("enemy"):
		body.take_damage(damage, global_position, false)
		body.velocity += direction * knockback
		
		if type == Type.VAMPIRE:
			player.health = min(player.health + 2, 8)
			player.ui.update_hearts(player.health)
		
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion():
		return
	
	if area.is_in_group("enemy_projectile"):
		if area.projectile_collide_cooldown.is_stopped():
			GlobalAudio.play_sfx(GlobalAudio.SFX.BLOCK)
			
			var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOCK)
			particles.position = global_position
			particles.emitting = true
			get_tree().root.add_child(particles)
			
			if not penetrating: queue_free()
			area.queue_free()
		
	elif area.is_in_group("headshot_area"):
		var enemy: Enemy = area.get_parent()
		
		enemy.take_damage(damage * enemy.headshot_mult, global_position, true)
		enemy.velocity += direction * knockback
		
		if type == Type.VAMPIRE:
			player.health = min(player.health + 2, 8)
			player.ui.update_hearts(player.health)
		
		queue_free()
