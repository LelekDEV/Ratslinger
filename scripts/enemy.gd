extends CharacterBody2D
class_name Enemy

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var projectiles: Node = get_tree().get_first_node_in_group("projectiles")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_extend_timer: Timer = $WalkExtendTimer
@onready var shoot_cooldown: Timer = $ShootCooldown

var _Projectile: PackedScene = preload("res://scenes/fox_projectile.tscn")

var speed: float = 30
var acceleration: float = 0.05
var max_health: float = 4
var health: float = max_health
var headshot_mult: float = 2  #for future development

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_shooting()
	
	move_and_slide()

func handle_shooting():
	var player_pos: Vector2 = player.global_position
	
	if shoot_cooldown.is_stopped() and global_position.distance_squared_to(player_pos) < 120 ** 2:
		var direction: Vector2 = (player.global_position - global_position).normalized()
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
	elif direction.x > 0:
		sprite.flip_h = false

func spawn_projectile(direction: Vector2) -> void:
	var shoot_pos = Vector2(14, 2) * Vector2(-1 if sprite.flip_h else 1, 0)
	
	var projectile = _Projectile.instantiate()
	
	projectile.global_position = global_position + shoot_pos
	projectile.global_rotation = direction.angle()
	projectile.direction = direction         
	  
	projectiles.add_child(projectile)

func take_damage(amount: float) -> void:
	health -= amount
	GlobalAudio.play()
	
	if health <= 0:
		queue_free()

func spawn_damage_particle(hit_position: Vector2) -> void:
	var particles = ParticleSpawner.instantiate(ParticleSpawner.ID.BLOOD)
	
	particles.emitting = true
	
	if is_queued_for_deletion():
		particles.global_position = global_position + (hit_position - global_position) * 0.5
		get_tree().root.add_child(particles)
	else:
		particles.position = (hit_position - global_position) * 0.5
		add_child(particles)

func hit_flash() -> void:
	sprite.material.set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	sprite.material.set_shader_parameter("active", false)
