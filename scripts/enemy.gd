extends CharacterBody2D
class_name Enemy

@onready var DamageIndicator: PackedScene = preload("res://scenes/damage_indicator.tscn")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var projectiles: Node2D = get_tree().get_first_node_in_group("projectiles")
@onready var coins: Node2D = get_tree().get_first_node_in_group("coins")
@onready var fx: Node2D = get_tree().get_first_node_in_group("fx")
@onready var enemies: Node2D = get_tree().get_first_node_in_group("enemies")

@onready var sprite: AnimatedSprite2D = $BaseSprite

@onready var poison_tick: Timer = $PoisonTick
@onready var poison_particles: CPUParticles2D = $PoisonParticles

@onready var fire_tick: Timer = $FireTick
@onready var fire_fx: Sprite2D = $FireFX

@export var speed: float = 30
var acceleration: float = 0.05
var direction: Vector2

var separation_radius: float = 30
var separation_weight: float = 8
var separation_vel: Vector2

@export var max_health: float = 8
var health: float

var poison_value: int = 0
var fire_value: int = 0

@export var damage: float = 1
var headshot_mult: float = 2

var drop_coins_enabled: bool = true

var attack_highlight: AttackHighlight

enum ID {FOX, COW, BEAVER, SNAKE}
@export var id: ID

# AI options
enum AI {SHOOTER, KICKER, SEGMENT}
@export var ai: AI

# 0 - SHOOTER: follow the player and shoot projectiles, used for FoxEnemy
# Used nodes and variables:
@onready var walk_extend_timer: Timer
@onready var shoot_cooldown: Timer
@onready var projectile_collide_cooldown: Timer
@onready var shoot_notion_timer: Timer

@onready var gun_sprite: Sprite2D

@export var cooldown_time: float = 1.5
@export var shoot_count: int = 1
@export var shoot_spread_deg: float = 0
@export var projectile_name: String

@export var min_player_distance: float = 80

# 1 - KICKER: remain stationary, trigger a kick attack on player's proximity, used for CowEnemy
# Used nodes and variables:
@onready var kick_delay: Timer

# 2 - SEGMENT: moves along other segments that share it's health, hurts player on collision, used for SnakeEnemy
# Used nodes and variables:
var is_vertical: bool = false

signal death
signal damaged

func _ready() -> void:
	match ai:
		AI.SHOOTER:
			walk_extend_timer = get_node("WalkExtendTimer")
			shoot_cooldown = get_node("ShootCooldown")
			shoot_notion_timer = get_node("ShootNotionTimer")
			
			gun_sprite = get_node("GunSprite")
			
		AI.KICKER:
			kick_delay = get_node("KickDelay")
	
	health = max_health
	
	sprite.material.set_shader_parameter("flash_active", false)
	sprite.material.set_shader_parameter("strip_active", false)

func _physics_process(_delta: float) -> void:
	if ai == AI.SHOOTER:
		handle_movement()
		handle_shooting()
	elif ai == AI.SEGMENT:
		velocity = Vector2.ZERO
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.3) # called as default logic to prevent infinite sliding from knockback for different AIs
	
	move_and_slide()

func handle_shooting() -> void:
	var player_pos: Vector2 = player.global_position
	direction = (player.global_position - gun_sprite.global_position).normalized()
	
	gun_sprite.global_rotation = direction.angle()
	
	if attack_highlight and not shoot_notion_timer.is_stopped():
		attack_highlight.target = player.global_position if shoot_spread_deg > 0 else direction * 400
		attack_highlight.alpha = abs(cos((1 - shoot_notion_timer.time_left / shoot_notion_timer.wait_time) * PI * 3)) * 0.5 + 0.5
	
	if shoot_cooldown.is_stopped() and global_position.distance_squared_to(player_pos) < 120 ** 2:
		shoot_notion_timer.start()
		shoot_cooldown.start(cooldown_time * randf_range(0.8, 1.2))
		
		attack_highlight = AttackHighlight.instantiate()
		
		attack_highlight.position = gun_sprite.position
		attack_highlight.arc_mode = shoot_spread_deg > 0
		attack_highlight.arc_spread = shoot_spread_deg / 2
		
		add_child(attack_highlight)

func handle_movement() -> void:
	separation_vel = Vector2.ZERO
	
	for enemy in enemies.get_children():
		if enemy is not Enemy:
			continue
		
		enemy = enemy as Enemy
		
		if enemy.ai != Enemy.AI.SHOOTER:
			continue
		
		var away: Vector2 = global_position - enemy.global_position
		var dist: float = away.length()
		
		if dist > 0 and dist < separation_radius:
			var strength: float = 1 - (dist / separation_radius)
			separation_vel += away.normalized() * strength
	
	var player_pos: Vector2 = player.global_position
	direction = (player_pos - global_position).normalized()
	
	if global_position.distance_squared_to(player_pos) > min_player_distance ** 2:
		velocity = lerp(velocity, (direction + separation_vel * separation_weight).normalized() * speed, 0.2)
		
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

func spawn_shotgun_projectile() -> void:
	for i in range(shoot_count):
		spawn_projectile((shoot_spread_deg / shoot_count) * i - shoot_spread_deg / 2) 

func spawn_projectile(angle_deg: float = 0) -> void:
	var shoot_dir = direction.rotated(deg_to_rad(angle_deg))
	var shoot_pos = Vector2(16, 16) * shoot_dir * 0
	
	var projectile = EnemyProjectile.instantiate(projectile_name)
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT)
	
	projectile.global_position = gun_sprite.global_position + shoot_pos
	projectile.global_rotation = shoot_dir.angle()
	projectile.direction = shoot_dir
	
	projectile.damage = damage
	projectile.parent = self
	
	particles.position = shoot_pos
	particles.global_rotation = shoot_dir.angle()
	particles.emitting = true  
	  
	projectiles.add_child(projectile)
	add_child(particles)

func die() -> void:
	death.emit(id)
	
	if drop_coins_enabled:
		drop_coins(randi_range(1, 2))
	
	queue_free()
	if attack_highlight: attack_highlight.queue_free()

func apply_poison() -> void:
	poison_value = 5
	poison_particles.emitting = true
	
	sprite.material.set_shader_parameter("strip_active", true)
	
	poison_tick.start()

func apply_fire() -> void:
	fire_value = 8
	fire_fx.visible = true
	
	fire_tick.start()

func take_damage(amount: float, hit_position: Vector2 = global_position, is_critical: bool = false, ignore_poison: bool = false) -> void:
	GlobalAudio.play_sfx(GlobalAudio.SFX.HIT)
	
	var final_amount = amount * (1.2 if poison_value >= 1 and not ignore_poison else 1.0)
	health -= final_amount
	
	if health <= 0:
		die()
	
	hit_flash()
	spawn_damage_fx(final_amount, hit_position, is_critical)
	
	damaged.emit(health, self)

func drop_coins(amount: int) -> void:
	for i in range(amount):
		var coin = Coin.instantiate()
		
		coin.global_position = global_position
		coin.velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * 0.5
		
		coins.call_deferred("add_child", coin)

func detach_attack_highlight() -> void:
	remove_child(attack_highlight)
	fx.add_child(attack_highlight)
	
	attack_highlight.global_position = global_position + gun_sprite.position
	attack_highlight.start_decay_tween()

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
	sprite.material.set_shader_parameter("flash_active", true)
	await get_tree().create_timer(0.1).timeout
	sprite.material.set_shader_parameter("flash_active", false)

func _on_kick_area_body_entered(body: Node2D) -> void:
	if body is Player:
		sprite.play("kick")
		kick_delay.start()

func _on_kick_delay_timeout() -> void:
	player.take_knockback(Vector2(-300, 0)) 
	player.take_damage(damage, null, self)

func _on_shoot_notion_timer_timeout() -> void:
	GlobalAudio.play_sfx(GlobalAudio.SFX.ENEMY_SHOOT, -6)
	
	detach_attack_highlight()
	spawn_shotgun_projectile()

func _on_hurt_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if is_vertical:
			if player.global_position.x > global_position.x:
				player.take_knockback(Vector2(300, 0))
			
			elif player.global_position.x < global_position.x:
				player.take_knockback(Vector2(-300, 0))
			
			else:
				player.take_knockback(Vector2(300, 0) if randi_range(0, 1) == 0 else Vector2(-300, 0))
		
		else:
			if player.global_position.y > global_position.y:
				player.take_knockback(Vector2(0, 300))
			
			elif player.global_position.y < global_position.y:
				player.take_knockback(Vector2(0, -300))
			
			else:
				player.take_knockback(Vector2(0, 300) if randi_range(0, 1) == 0 else Vector2(0, -300))
		
		player.take_damage(damage, null, self)

func _on_poison_tick_timeout() -> void:
	take_damage(0.5, global_position, false, true)
	poison_value -= 1
	
	if poison_value >= 1:
		poison_tick.start()
	else:
		poison_particles.emitting = false
		sprite.material.set_shader_parameter("strip_active", false)

func _on_fire_tick_timeout() -> void:
	take_damage(0.25, global_position, false, true)
	fire_value -= 1
	
	if fire_value >= 1:
		fire_tick.start()
	else:
		fire_fx.visible = false
