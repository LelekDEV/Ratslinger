extends CharacterBody2D
class_name Player

@onready var projectiles: Node = get_tree().get_first_node_in_group("projectiles")
@onready var hearts: Array = get_tree().get_nodes_in_group("hearts")

@onready var heart_left = hearts[0]
@onready var heart_right = hearts[1]

@onready var gun_sprite: Sprite2D = $GunSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var legs_sprite: AnimatedSprite2D = $LegsSprite

@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var hit_cooldown: Timer = $HitCooldown

var max_hp: int = 8
var hp: int = max_hp
var is_dead: bool = false   

var speed: float = 75
var acceleration: float = 0.05
var recoil: float = 50

var input: Vector2

var anim: float = 0

func play_sfx():
	if hp == 0 and not is_dead:
		GlobalAudio.get_node("Loose").play()
		is_dead = !is_dead
		print("player is dead!")
		

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


func kick_recoil(amount: int):
	
	var direction: Vector2 = get_local_mouse_position().normalized()
	velocity -= direction * amount

func take_damage(amount: int) -> void:
	if hit_cooldown.is_stopped():
		hp = max(hp - amount, 0)
	
		if heart_right.frame < 4:
			heart_right.frame += 1
		else:
			heart_left.frame += 1
	
		play_sfx()
		hit_cooldown.start()
