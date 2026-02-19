extends Area2D
class_name Projectile

@onready var ChompFX: PackedScene = preload("res://scenes/fx/chomp_fx.tscn")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var fx: Node2D = get_tree().get_first_node_in_group("fx")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var special_particles_dark: CPUParticles2D = $SpecialParticles/Dark
@onready var special_particles_light: CPUParticles2D = $SpecialParticles/Light

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
		special_particles_dark.emitting = true
		special_particles_light.emitting = true
		special_particles_dark.color = Consts.SPECIAL_BULLETS_COLORS.dark[type]
		special_particles_light.color = Consts.SPECIAL_BULLETS_COLORS.light[type]
		
		if type == Type.VAMPIRE:
			sprite.play("vampire")
		elif type == Type.FIRE:
			sprite.play("fire")
		elif type == Type.POISON:
			sprite.play("poison")

func _physics_process(delta: float) -> void:
	velocity = direction * speed * delta
	global_position += velocity

func damage_and_destroy(enemy: Enemy, is_critical: bool) -> void:
	enemy.take_damage(damage * enemy.headshot_mult if is_critical else 1.0, global_position, is_critical)
	enemy.velocity += direction * knockback
	
	if type == Type.VAMPIRE:
		player.health = min(player.health + 2, 8)
		player.ui.update_hearts(player.health)
		
		var chomp_fx: AnimatedSprite2D = ChompFX.instantiate()
		chomp_fx.global_position = global_position
		fx.add_child(chomp_fx)
		
		var heal_particles = ParticleSpawner.instantiate(ParticleSpawner.ID.HEAL)
		heal_particles.position.y = 8
		heal_particles.emitting = true
		player.add_child(heal_particles)
		
		GlobalAudio.play_sfx(AudioConsts.SFX.PLAYER_SHOOT_VAMPIRE, -12, 1, 0.2)
	
	elif type == Type.POISON:
		enemy.apply_poison()
	
	elif type == Type.FIRE:
		enemy.apply_fire()
	
	queue_free()

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	
	if body.is_in_group("enemy"):
		damage_and_destroy(body, false)

func _on_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion():
		return
	
	if area.is_in_group("enemy_projectile"):
		if area.projectile_collide_cooldown.is_stopped():
			GlobalAudio.play_sfx(AudioConsts.SFX.BLOCK)
			
			var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOCK)
			particles.position = global_position
			particles.emitting = true
			get_tree().root.add_child(particles)
			
			if not penetrating: queue_free()
			area.queue_free()
		
	elif area.is_in_group("headshot_area"):
		damage_and_destroy(area.get_parent(), true)
