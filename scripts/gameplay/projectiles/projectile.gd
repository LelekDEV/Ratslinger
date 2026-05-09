extends Area2D
class_name Projectile

@onready var ChompFX: PackedScene = preload("res://scenes/fx/combat/chomp_fx.tscn")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var fx: Node2D = get_tree().get_first_node_in_group("fx")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var special_particles_dark: CPUParticles2D
@onready var special_particles_light: CPUParticles2D

var damage: float = 1
var knockback: float = 150

var speed: float = 150
var direction: Vector2
var velocity: Vector2
var penetrating: bool = false

enum Type {REGULAR = -1, VAMPIRE, FIRE, POISON}
var type: Type = Type.REGULAR

@export var use_special_particles: bool = true

enum Action {REGULAR, STATIONARY, WAVE}
@export var action: Action
var ignored_enemies: Array
var ignored_bounce_enemies: Array

var debounced_enemies: int = 0

enum ProjectileKind {REGULAR, SHOTGUN, TROMBONE}

static func instantiate(kind: ProjectileKind = ProjectileKind.REGULAR) -> Projectile:
	match kind:
		ProjectileKind.SHOTGUN:
			return preload("res://scenes/world/projectiles/shotgun_projectile.tscn").instantiate()
		ProjectileKind.TROMBONE:
			return preload("res://scenes/world/projectiles/trombone_projectile.tscn").instantiate()
		_:
			return preload("res://scenes/world/projectiles/projectile.tscn").instantiate()

func _ready() -> void:
	if use_special_particles:
		special_particles_dark = $SpecialParticles/Dark
		special_particles_light = $SpecialParticles/Light
	
	if type != Type.REGULAR:
		if use_special_particles:
			special_particles_dark.emitting = true
			special_particles_light.emitting = true
			special_particles_dark.color = Consts.SPECIAL_BULLETS_COLORS.dark[type]
			special_particles_light.color = Consts.SPECIAL_BULLETS_COLORS.light[type]
		
		if action != Action.WAVE:
			if type == Type.VAMPIRE:
				sprite.play("vampire")
			elif type == Type.FIRE:
				sprite.play("fire")
			elif type == Type.POISON:
				sprite.play("poison")
	
	if action == Action.WAVE:
		direction *= -1

func _physics_process(delta: float) -> void:
	if action == Action.REGULAR or action == Action.WAVE:
		velocity = direction * speed * delta
		global_position += velocity

func block_and_destroy(projectile: EnemyProjectile) -> void:
	GlobalAudio.play_sfx(AudioConsts.SFX.BLOCK)
	
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOCK)
	particles.position = global_position
	particles.emitting = true
	get_tree().root.add_child(particles)
	
	if not penetrating and action == Action.REGULAR:
		queue_free()
	
	projectile.queue_free()

func damage_and_destroy(enemy: Enemy, is_critical: bool) -> void:
	if enemy in ignored_enemies:
		return
	
	enemy.take_damage(damage * enemy.headshot_mult if is_critical else 1.0, global_position, is_critical, false, self)
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
	
	if action == Action.REGULAR:
		if not enemy.free_on_death and enemy.health <= 0:
			await SignalBus.boss_death_anim_ended

		queue_free()
	
	ignored_enemies.append(enemy)
	
	if action == Action.WAVE:
		ignored_bounce_enemies.append(enemy)
		var dist: float = INF
		var closest_eminem_pos: Vector2

		for eminem: Enemy in Global.all_enemies:
			if eminem in ignored_bounce_enemies:
				continue
			
			var new_dist: float = eminem.global_position.distance_squared_to(global_position)
			if new_dist < dist:
				dist = new_dist
				closest_eminem_pos = eminem.global_position
		
		direction = global_position.direction_to(closest_eminem_pos)
		sprite.global_rotation = direction.angle() + PI
		handle_bouce()

func handle_bouce() -> void:
	debounced_enemies += 1
	
	if debounced_enemies == 1:
		sprite.play("m_wave")
	elif debounced_enemies == 2:
		sprite.play("s_wave")
	
	elif debounced_enemies == 3:
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
		if area.projectile_collide_cooldown.is_stopped() or action == Action.STATIONARY:
			block_and_destroy(area)
		
	elif area.is_in_group("headshot_area"):
		match action:
			Action.REGULAR: damage_and_destroy(area.get_parent(), true)
			Action.STATIONARY: damage_and_destroy(area.get_parent(), false)

func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.visible = false
