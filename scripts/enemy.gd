extends CharacterBody2D
class_name Enemy

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_extend_timer: Timer = $WalkExtendTimer
@onready var hit_sfx: AudioStreamPlayer = $"../../AudioStreamPlayer"
@onready var bullets_container: Node = $"../../Bullets"
@onready var shoot_cooldown: Timer = $Shoot_Cooldown

const BULLET_SCENE:= preload("res://scenes/foxbullet.tscn")


var speed: float = 30
var acceleration: float = 0.05
var max_health: float = 4
var health: float = max_health
var player_pos

func _physics_process(_delta: float) -> void:
	player_pos = player.global_position
	var direction = (player_pos - global_position).normalized()
	
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
	
	move_and_slide()
	if global_position.distance_squared_to(player_pos) < 120 ** 2:
		handle_shooting()
	
func handle_shooting():
	if shoot_cooldown.is_stopped():
		var direction: Vector2 = (player.global_position - global_position).normalized()
		spawn_bullet(direction)
		shoot_cooldown.start()

func spawn_bullet(direction: Vector2) -> void:
	if shoot_cooldown.is_stopped():
		var bullet = BULLET_SCENE.instantiate()
		bullet.global_position = global_position
		bullet.global_rotation = direction.angle()
		bullet.direction = direction           
		bullets_container.add_child(bullet)

func take_damage(amount: float) -> void:
	health -= amount
	hit_sfx.play()
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
