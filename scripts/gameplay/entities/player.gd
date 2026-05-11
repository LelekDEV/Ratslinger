extends CharacterBody2D
class_name Player

@onready var ui: CanvasLayer = get_tree().get_first_node_in_group("ui")
@onready var projectiles: Node = get_tree().get_first_node_in_group("projectiles")
@onready var markers: Node2D = get_tree().get_first_node_in_group("markers")

@onready var accuracy_bar: AccuracyBar = get_tree().get_first_node_in_group("accuracy_bar")
@onready var bullet_bar: BulletBar = get_tree().get_first_node_in_group("bullet_bar")

@onready var gun_sprite: AnimatedSprite2D = $GunSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var legs_sprite: AnimatedSprite2D = $LegsSprite

@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var hit_cooldown: Timer = $HitCooldown
@onready var regen_cooldown: Timer = $RegenCooldown
@onready var reload_timer: Timer = $ReloadTimer

@onready var squeeze_lock: SqueezeLock = $SqueezeLock

@onready var local_fx: Node2D = $LocalFX
@onready var dash_particles: CPUParticles2D = $DashParticles

@export var gate: StaticBody2D

var max_health: float = 8
var health: float = max_health
var ignored_hitter: Enemy

var is_dead: bool = false
var is_queued_to_die: bool = false

var is_squeezed: bool = false

var speed: float = 75
var acceleration: float = 0.05
var recoil_values: Array = [50.0, 120.0, -500.0]

var input: Vector2

var anim: float = 0

var squeeze_anim_tween: Tween
var squeeze_anim_value: float = 0

enum Locations {ARENA, TOWN, TOWN_HALL}
var location: Locations = Locations.ARENA
var last_location: Locations = location

enum Guns {REVOLVER, SHOTGUN, TROMBONE}
var gun: Guns = Guns.REVOLVER

func _ready() -> void:
	SignalBus.game_save_queued.connect(_on_game_save_queued)
	
	squeeze_lock.right_key_pressed.connect(squeeze_anim)
	
	if Global.is_game_restarted and not Global.is_title_restarted:
		set_deferred("global_position", Vector2.ZERO)
	
	if Global.is_title_on:
		Global.block_movement = true
		Global.block_input = true
	
	# switch_gun(Guns.SHOTGUN)

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_shooting()
	handle_locations()
	handle_squeeze()
	
	move_and_slide()

func switch_gun(new_gun: Guns) -> void:
	if is_squeezed:
		return
	
	gun = new_gun

	var frame: int = base_sprite.frame
	var progress: float = base_sprite.frame_progress
	
	match gun:
		Guns.REVOLVER:
			gun_sprite.play("revolver")
			gun_sprite.z_index = 0
			gun_sprite.offset.x = 11.5
			
			base_sprite.play("default")
		
		Guns.SHOTGUN:
			gun_sprite.play("shotgun_shoot", 0)
			gun_sprite.z_index = 1
			gun_sprite.offset.x = 3.5
			
			base_sprite.play("handless")
		
		Guns.TROMBONE:
			gun_sprite.play("trombone")
			gun_sprite.z_index = 1
			gun_sprite.offset.x = -1.5

	base_sprite.set_frame_and_progress(frame, progress)

func reload_bullets(full: bool = false) -> void:
	accuracy_bar.reload_bullets = false
	accuracy_bar.progress_time = bullet_bar.current_slot * 0.3
	accuracy_bar.start()
	
	bullet_bar.assign_specials(full)
	
	reload_timer.start()
	
	if full: await get_tree().create_timer(0.35, false).timeout
	if gun == Guns.SHOTGUN: gun_sprite.play("shotgun_reload")

func spawn_projectile(direction: Vector2) -> bool:
	var is_special: bool = false
	var shoot_offset: Vector2 = Vector2(0, 2 + int(gun == Guns.SHOTGUN) * 3 - int(gun == Guns.TROMBONE) * 7)
	var shoot_pos := Vector2.ONE * (16 + int(gun == Guns.SHOTGUN) * 8) * direction + shoot_offset
	
	var projectile: Projectile
	
	match gun:
		Guns.REVOLVER: projectile = Projectile.instantiate()
		Guns.SHOTGUN: projectile = Projectile.instantiate(Projectile.ProjectileKind.SHOTGUN)
		Guns.TROMBONE:
			shoot_pos *= -1
			projectile = Projectile.instantiate(Projectile.ProjectileKind.TROMBONE)
		
	var particles: CPUParticles2D
	
	match gun:
		Guns.REVOLVER:
			particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT)
			particles.position = shoot_pos
		
		Guns.SHOTGUN: 
			particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT_HEAVY)
			particles.position = Vector2.ONE * 8 * direction + shoot_offset
		
		Guns.TROMBONE:
			particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT_SOUND_WAVE)
			particles.position = shoot_pos

	projectile.global_position = global_position + shoot_pos
	projectile.global_rotation = direction.angle()
	projectile.direction = direction
	
	if accuracy_bar.get_type_from_value(accuracy_bar.progress_value) == 2:
		if gun == Guns.REVOLVER:
			projectile.speed *= 1.5
			projectile.knockback *= 3
			projectile.penetrating = true
		
		elif gun == Guns.TROMBONE:
			projectile.get_node("DeathTimer").wait_time = 1
		
		var type: Projectile.Type = bullet_bar.slot_types[bullet_bar.current_slot]
		projectile.type = type
		
		if type != Projectile.Type.REGULAR:
			is_special = true
	
	particles.global_rotation = direction.angle()
	particles.emitting = true
	
	projectiles.add_child(projectile)
	add_child(particles)
	
	return is_special

func handle_locations() -> void:
	if location == Locations.TOWN_HALL:
		return

	if global_position.x > gate.global_position.x:
		location = Locations.ARENA
	else:
		location = Locations.TOWN
	
	if last_location != location:
		SignalBus.player_location_change.emit(location)
	
	last_location = location

func is_gun_unlocked(check_gun: Guns) -> bool:
	match check_gun:

		Guns.REVOLVER:
			return true

		Guns.SHOTGUN:
			return Upgrades.unlocked_weapons[0]

		Guns.TROMBONE:
			return Upgrades.unlocked_weapons[1]

	return false

func cycle_guns() -> void:
	for i in Guns.size():
		var next_gun = (gun + 1) % Guns.size()
		
		if is_gun_unlocked(next_gun):
			switch_gun(next_gun)
			return

func handle_shooting() -> void:
	if Input.is_action_just_pressed("switch_gun"):
		@warning_ignore("int_as_enum_without_cast")
		cycle_guns()
	
	if Input.is_action_just_pressed("shoot") and \
		shoot_cooldown.is_stopped() and \
		reload_timer.is_stopped() and \
		not Global.block_input and \
		not is_squeezed or \
		Global.force_input:
		
		accuracy_bar.reload_bullets = false if bullet_bar.current_slot == 5 else true
		
		if accuracy_bar.get_type_from_value(accuracy_bar.progress_value) == 0:
			SignalBus.player_shoot.emit(true)
			return
		
		var direction: Vector2 = get_local_mouse_position().normalized()
		var is_special: bool = spawn_projectile(direction)
		
		var recoil: float
		
		match gun:
			Guns.REVOLVER: recoil = recoil_values[0]
			Guns.SHOTGUN: recoil = recoil_values[1] / (int(accuracy_bar.get_type_from_value(accuracy_bar.progress_value) == 2) + 1)
			Guns.TROMBONE: recoil = recoil_values[2]
		
		velocity -= direction * recoil
		
		if is_special:
			GlobalAudio.play_sfx(AudioConsts.SFX.PLAYER_SHOOT_SPECIAL, -4)
		else:
			GlobalAudio.play_sfx(AudioConsts.SFX.PLAYER_SHOOT, -4)
		
		regen_cooldown.start(5)
		
		if gun == Guns.SHOTGUN:
			gun_sprite.play("shotgun_shoot")
		elif gun == Guns.TROMBONE:
			dash_particles.emitting = true
		
		SignalBus.player_shoot.emit(false)
		Global.force_input = false

func handle_movement() -> void:
	# TO DO: should probably split some bits into handle_animation
	if Global.block_movement or is_squeezed:
		input = Vector2.ZERO
	else:
		input = Input.get_vector("left", "right", "up", "down")
	
	legs_sprite.play("walk" if input.length() > 0 else "idle")
	
	var flip: bool = get_global_mouse_position().x > global_position.x
	if is_squeezed: flip = true
	
	if flip:
		gun_sprite.flip_v = false
		base_sprite.flip_h = false
		legs_sprite.flip_h = false
	else:
		gun_sprite.flip_v = true
		base_sprite.flip_h = true
		legs_sprite.flip_h = true
	
	gun_sprite.position.y = 3.5 + int(base_sprite.frame == 2) + int(gun == Guns.SHOTGUN) * 3 + int(gun == Guns.TROMBONE) * 0.5
	gun_sprite.global_rotation = get_angle_to(get_global_mouse_position())
	
	dash_particles.position = base_sprite.position
	dash_particles.texture.region.position.x = 0 if flip else 37
	
	for fx in local_fx.get_children():
		if fx.has_meta("flippable_pos"):
			fx.position = (fx.get_meta("flippable_pos") - floor(Vector2(37, 32) / 2)) * Vector2(1 if flip else -1, 1)
			fx.visible = true
	
	velocity = Global.fixed_lerp(velocity, input * speed, acceleration)

func handle_squeeze() -> void:
	base_sprite.offset.y = (1 - abs(squeeze_anim_value - 1)) * -5

func squeeze_anim() -> void:
	if squeeze_anim_tween:
		squeeze_anim_tween.kill()
	
	squeeze_anim_value = 0
	
	squeeze_anim_tween = create_tween() \
		.set_ease(Tween.EASE_OUT_IN) \
		.set_trans(Tween.TRANS_CUBIC)
	
	squeeze_anim_tween.tween_property(self, "squeeze_anim_value", 2, 0.25)
	if not squeeze_lock.is_locked: squeeze_anim_tween.tween_callback(exit_squeeze)
	
	GlobalAudio.play_sfx(AudioConsts.SFX.BLOCK, -4, 1.2)

func enter_squeeze() -> void:
	is_squeezed = true
	gun_sprite.visible = false
	legs_sprite.visible = false
	
	base_sprite.play("squeeze")
	
	squeeze_lock.lock()

func exit_squeeze() -> void:
	is_squeezed = false
	gun_sprite.visible = true
	legs_sprite.visible = true
	
	base_sprite.play("default")
	
	var particles: CPUParticles2D = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOOD)
	particles.global_position = global_position
	particles.emitting = true
	get_tree().get_root().add_child(particles)
	
	GlobalAudio.play_sfx(AudioConsts.SFX.HISS, -10, 1.2)

func take_knockback(vector: Vector2) -> void:
	if not hit_cooldown.is_stopped():
		return
	
	velocity += vector

func take_damage(amount: float, from_projectile: EnemyProjectile = null, from_enemy: Enemy = null) -> bool:
	# (returns true if it's lethal, false otherwise)
	
	if not hit_cooldown.is_stopped() and from_enemy != ignored_hitter:
		return false
	
	SignalBus.player_hit.emit()
	
	if from_enemy and from_enemy.ai != Enemy.AI.SEGMENT:
		ignored_hitter = from_enemy
	
	health -= amount
	
	if health <= 0 and not is_queued_to_die:
		GlobalAudio.play_sfx(AudioConsts.SFX.LOSE)
		SignalBus.player_death.emit(from_projectile, from_enemy)
		Global.death_wave = Global.waves_cleared
		
		is_queued_to_die = true
		
		return true
	
	ui.update_hearts(health)
	
	GlobalAudio.play_sfx(AudioConsts.SFX.HIT)
	
	hit_cooldown.start(0.5 if Global.game.is_boss_active else 0.25)
	regen_cooldown.start(5)
	
	return false

func _on_reload_timer_timeout() -> void:
	bullet_bar.load_slot()
	
	if not bullet_bar.current_slot == 0:
		reload_timer.start()
	else:
		shoot_cooldown.start()

func _on_game_save_queued() -> void:
	if location == Locations.TOWN_HALL:
		global_position = markers.points.rat_house_exit_pos

func _on_regen_cooldown_timeout() -> void:
	health = min(health + 0.2, max_health)
	ui.update_hearts(health)
	regen_cooldown.start(1)

func _on_hit_cooldown_timeout() -> void:
	SignalBus.player_immunity_ended.emit()
