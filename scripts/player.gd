extends CharacterBody2D
class_name Player

@onready var ui: CanvasLayer = get_tree().get_first_node_in_group("ui")
@onready var projectiles: Node = get_tree().get_first_node_in_group("projectiles")

@onready var gun_sprite: Sprite2D = $GunSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var legs_sprite: AnimatedSprite2D = $LegsSprite

@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var hit_cooldown: Timer = $HitCooldown

var max_health: float = 8
var health: float = max_health
var is_dead: bool = false   

var speed: float = 75
var acceleration: float = 0.05
var recoil: float = 50

var input: Vector2

var anim: float = 0

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_shooting()
	
	move_and_slide()

func spawn_projectile(direction: Vector2) -> void:
	var shoot_pos = Vector2(16, 16) * direction + Vector2(0, 2)
	
	var projectile = Projectile.instantiate()
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.SHOOT)
	
	projectile.global_position = global_position + shoot_pos
	projectile.global_rotation = direction.angle()
	projectile.direction = direction
	
	particles.position = shoot_pos
	particles.global_rotation = direction.angle()
	particles.emitting = true
	
	projectiles.add_child(projectile)
	add_child(particles)

func handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot") and shoot_cooldown.is_stopped():
		GlobalAudio.play_sfx(GlobalAudio.SFX.PLAYER_SHOOT, -4)
		
		var direction: Vector2 = get_local_mouse_position().normalized()
		
		spawn_projectile(direction)
		
		velocity -= direction * recoil
		
		shoot_cooldown.start()
		SignalBus.player_shoot.emit()

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

func take_damage(amount: float) -> void:
	if not hit_cooldown.is_stopped():
		return
		
	health -= amount
		
	if health <= 0:
		GlobalAudio.play_sfx(GlobalAudio.SFX.LOSE)
			
		# Retrieve to max health as placeholder
		health = max_health
			
		print("You died")
		
	ui.update_hearts(health)
		
	GlobalAudio.play_sfx(GlobalAudio.SFX.HIT)
	hit_cooldown.start()
