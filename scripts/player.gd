extends CharacterBody2D
class_name Player

@onready var ui: CanvasLayer = get_tree().get_first_node_in_group("ui")
@onready var projectiles: Node = get_tree().get_first_node_in_group("projectiles")

@onready var accuracy_bar: AccuracyBar = get_tree().get_first_node_in_group("accuracy_bar")
@onready var bullet_bar: BulletBar = get_tree().get_first_node_in_group("bullet_bar")

@onready var gun_sprite: Sprite2D = $GunSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var legs_sprite: AnimatedSprite2D = $LegsSprite

@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var hit_cooldown: Timer = $HitCooldown
@onready var reload_timer: Timer = $ReloadTimer

@export var gate: StaticBody2D

var max_health: float = 8
var health: float = max_health
var ignored_hitter: Enemy

var is_dead: bool = false
var is_queued_to_die: bool = false

var speed: float = 75
var acceleration: float = 0.05
var recoil: float = 50

var input: Vector2

var anim: float = 0

enum Locations {ARENA, TOWN}
var location: Locations = Locations.ARENA
var last_location: Locations = location

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_shooting()
	handle_locations()
	
	move_and_slide()

func reload_bullets(full: bool = false) -> void:
	accuracy_bar.reload_bullets = false
	accuracy_bar.progress_time = bullet_bar.current_slot * 0.3
	accuracy_bar.start()
	
	bullet_bar.assign_specials(full)
	
	reload_timer.start()

func spawn_projectile(direction: Vector2) -> bool:
	var is_special: bool = false
	var shoot_pos = Vector2(16, 16) * direction + Vector2(0, 2)
	
	var projectile = Projectile.instantiate()
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT)
	
	projectile.global_position = global_position + shoot_pos
	projectile.global_rotation = direction.angle()
	projectile.direction = direction
	
	if accuracy_bar.get_type_from_value(accuracy_bar.progress_value) == 2:
		projectile.speed *= 1.5
		projectile.knockback *= 3
		projectile.penetrating = true
		
		var type: Projectile.Type = bullet_bar.slot_types[bullet_bar.current_slot]
		projectile.type = type
		
		if type != Projectile.Type.REGULAR:
			is_special = true
	
	particles.position = shoot_pos
	particles.global_rotation = direction.angle()
	particles.emitting = true
	
	projectiles.add_child(projectile)
	add_child(particles)
	
	return is_special

func handle_locations() -> void:
	if global_position.x > gate.global_position.x:
		location = Locations.ARENA
	else:
		location = Locations.TOWN
	
	if last_location != location:
		SignalBus.player_location_change.emit(location)
	
	last_location = location

func handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot") and \
		shoot_cooldown.is_stopped() and \
		reload_timer.is_stopped() and \
		not Global.block_input:
		
		accuracy_bar.reload_bullets = false if bullet_bar.current_slot == 5 else true
		
		if accuracy_bar.get_type_from_value(accuracy_bar.progress_value) == 0:
			SignalBus.player_shoot.emit(true)
			return
		
		var direction: Vector2 = get_local_mouse_position().normalized()
		var is_special: bool = spawn_projectile(direction)
		
		velocity -= direction * recoil
		
		if is_special:
			GlobalAudio.play_sfx(GlobalAudio.SFX.PLAYER_SHOOT_VAMPIRE, -12)
		else:
			GlobalAudio.play_sfx(GlobalAudio.SFX.PLAYER_SHOOT, -4)
		
		SignalBus.player_shoot.emit(false)

func handle_movement() -> void:
	input = Input.get_vector("left", "right", "up", "down")
	
	legs_sprite.play("walk" if input.length() > 0 else "idle")
	
	if get_global_mouse_position().x > global_position.x:
		gun_sprite.flip_v = false
		base_sprite.flip_h = false
		legs_sprite.flip_h = false
	else:
		gun_sprite.flip_v = true
		base_sprite.flip_h = true
		legs_sprite.flip_h = true
	
	if base_sprite.frame == 2:
		gun_sprite.position.y = 4.5
	else:
		gun_sprite.position.y = 3.5
	
	gun_sprite.global_rotation = get_angle_to(get_global_mouse_position())
	
	velocity = lerp(velocity, input * speed, acceleration)

func take_knockback(vector: Vector2) -> void:
	if not hit_cooldown.is_stopped():
		return
	
	velocity += vector

func take_damage(amount: float, from_projectile: EnemyProjectile = null, from_enemy: Enemy = null) -> bool:
	# (returns true if it's lethal, false otherwise)
	
	if not hit_cooldown.is_stopped() and from_enemy != ignored_hitter:
		return false
	
	SignalBus.player_hit.emit()
	
	ignored_hitter = from_enemy
	health -= amount
	
	if health <= 0 and not is_queued_to_die:
		GlobalAudio.play_sfx(GlobalAudio.SFX.LOSE)
		SignalBus.player_death.emit(from_projectile, from_enemy)
		
		is_queued_to_die = true
		
		return true
	
	ui.update_hearts(health)
	
	GlobalAudio.play_sfx(GlobalAudio.SFX.HIT)
	hit_cooldown.start()
	
	return false

func _on_reload_timer_timeout() -> void:
	bullet_bar.load_slot()
	
	if not bullet_bar.current_slot == 0:
		reload_timer.start()
	else:
		shoot_cooldown.start()
