extends CharacterBody2D
class_name Enemy

@onready var DamageIndicator: PackedScene = preload("res://scenes/damage_indicator.tscn")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var projectiles: Node = get_tree().get_first_node_in_group("projectiles")

@onready var sprite: AnimatedSprite2D = $BaseSprite
@onready var gun_sprite: Sprite2D

@onready var walk_extend_timer: Timer# = $WalkExtendTimer
@onready var shoot_cooldown: Timer# = $ShootCooldown
@onready var kick_delay: Timer# = $KickDelay
@onready var projectile_collide_cooldown: Timer

var speed: float = 30
var acceleration: float = 0.05

@export var max_health: float = 8
var health: float

@export var damage: float = 1
var headshot_mult: float = 2

# AI options
# 0 - SHOOTER: follow the player and shoot projectiles, used for FoxEnemy
# 1 - KICKER: remain stationary, trigger a kick attack on player's proximity, used for CowEnemy
enum AI {SHOOTER, KICKER}
@export var ai: AI

func _ready() -> void:
	match ai:
		AI.SHOOTER:
			walk_extend_timer = get_node("WalkExtendTimer")
			shoot_cooldown = get_node("ShootCooldown")
			gun_sprite = get_node("GunSprite")
		AI.KICKER:
			kick_delay = get_node("KickDelay")
	
	health = max_health

func _physics_process(_delta: float) -> void:
	if ai == AI.SHOOTER:
		handle_movement()
		handle_shooting()
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.3) # called as default logic to prevent infinite sliding from knockback for different AIs
	
	move_and_slide()

func handle_shooting() -> void:
	var player_pos: Vector2 = player.global_position
	var direction: Vector2 = (player.global_position - global_position).normalized()
	
	gun_sprite.global_rotation = direction.angle()
	
	if shoot_cooldown.is_stopped() and global_position.distance_squared_to(player_pos) < 120 ** 2:
		GlobalAudio.play_sfx(GlobalAudio.SFX.ENEMY_SHOOT, -6)
		
		spawn_projectile(direction)
		shoot_cooldown.start()

func handle_movement() -> void:
	var player_pos: Vector2 = player.global_position
	var direction: Vector2 = (player_pos - global_position).normalized()
	
	if global_position.distance_squared_to(player_pos) > 80 ** 2:
		velocity = lerp(velocity, speed * direction, 0.2)
		
		if velocity.length() > 0:
			sprite.play("walk")
			walk_extend_timer.start()
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.2)
		
		if walk_extend_timer.is_stopped():
			sprite.play("idle")
	
	if direction.x < 0:
		sprite.flip_h = true
		gun_sprite.flip_v = true
	elif direction.x > 0:
		sprite.flip_h = false
		gun_sprite.flip_v = false

func spawn_projectile(direction: Vector2) -> void:
	var shoot_pos = Vector2(16, 16) * direction
	
	var projectile = EnemyProjectile.instantiate()
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT)
	
	projectile.global_position = global_position + shoot_pos
	projectile.global_rotation = direction.angle()
	projectile.direction = direction
	
	particles.position = shoot_pos
	particles.global_rotation = direction.angle()
	particles.emitting = true  
	  
	projectiles.add_child(projectile)
	add_child(particles)

func take_damage(amount: float, hit_position: Vector2 = global_position, is_critical: bool = false) -> void:
	health -= amount
	
	GlobalAudio.play_sfx(GlobalAudio.SFX.HIT)
	
	if health <= 0:
		queue_free()
	
	hit_flash()
	spawn_damage_fx(amount, hit_position, is_critical)

func spawn_damage_fx(amount: float, hit_position: Vector2, is_critical: bool) -> void:
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOOD)
	var indicator = DamageIndicator.instantiate()
	
	particles.emitting = true
	
	if is_queued_for_deletion():
		particles.global_position = global_position + (hit_position - global_position) * 0.5
		get_tree().root.add_child(particles)
	else:
		particles.position = (hit_position - global_position) * 0.5
		add_child(particles)
	
	indicator.text = str(amount)
	indicator.global_position = hit_position
	indicator.is_critical = is_critical
	
	get_tree().root.add_child(indicator)

func hit_flash() -> void:
	sprite.material.set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	sprite.material.set_shader_parameter("active", false)

func _on_kick_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.play("kick")
		kick_delay.start()

func _on_kick_delay_timeout() -> void:
	player.velocity -= Vector2(300, 0)
	player.take_damage(damage)
