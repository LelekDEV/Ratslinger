extends Node2D
class_name SnakeEnemyWrapper

@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var fx: Node2D = get_tree().get_first_node_in_group("fx")

var Segment: PackedScene = preload("res://scenes/enemies/snake_enemy_segment.tscn")

var length: int = 20
var speed: float = 150
var direction: Vector2 = Vector2.LEFT
var attack_margin: float = 150

signal death

func _ready() -> void:
	for i in range(length):
		var segment: Enemy = Segment.instantiate()
		
		if i == 0:
			segment.get_node("BaseSprite").play("head")
			segment.get_node("HeadshotArea/CollisionShapeHead").disabled = false
			segment.damage = 2
		else:
			if i == length - 1:
				segment.get_node("BaseSprite").play("tail")
			else:
				segment.get_node("BaseSprite").play("body")
			
			segment.damage = 1
			segment.position.x = i * 17 + 3
		
		segment.damaged.connect(link_health)
		segment.poison_start.connect(link_poision.bind(i))
		segment.poison_end.connect(func():
			for other in get_children():
				other.poison_value = 0
				other.poison_particles.emitting = false
				other.sprite.material.set_shader_parameter("strip_active", false)
		)
		
		add_child(segment)
	
	attack()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	
	var half_screen: Vector2 = get_viewport_rect().size / 2 / camera.zoom.x
	var pixel_length: int = length * 17 + 3
	
	var statements: Array = [
		direction == Vector2.LEFT and global_position.x + pixel_length < camera.global_position.x - half_screen.x,
		direction == Vector2.RIGHT and global_position.x - pixel_length > camera.global_position.x + half_screen.x,
		direction == Vector2.UP and global_position.y + pixel_length < camera.global_position.y - half_screen.y,
		direction == Vector2.DOWN and global_position.y - pixel_length > camera.global_position.y + half_screen.y
	]
	
	if true in statements:
		attack()

func apply_offsets(offset: Vector2) -> void:
	for segment in get_children():
		segment.get_node("FireFX").position = offset

func attack() -> void:
	var half_screen: Vector2 = get_viewport_rect().size / 2 / camera.zoom.x
	var dir_roll = randi_range(0, 3)
	
	if dir_roll <= 1:
		global_position.y = player.global_position.y
		
		for segment in get_children():
			segment.is_vertical = false
		
		if dir_roll == 0:
			global_position.x = camera.global_position.x + half_screen.x + attack_margin
			global_rotation = 0
			direction = Vector2.LEFT
			apply_offsets(Vector2(-2, -6.5))
		else:
			global_position.x = camera.global_position.x - half_screen.x - attack_margin
			global_rotation = PI
			direction = Vector2.RIGHT
			apply_offsets(Vector2(-2, 6.5))
	
	else:
		global_position.x = player.global_position.x
		
		for segment in get_children():
			segment.is_vertical = true
		
		if dir_roll == 2:
			global_position.y = camera.global_position.y + half_screen.y + attack_margin
			global_rotation = PI / 2
			direction = Vector2.UP
			apply_offsets(Vector2(-10, 0))
		else:
			global_position.y = camera.global_position.y - half_screen.y - attack_margin
			global_rotation = -PI / 2
			direction = Vector2.DOWN
			apply_offsets(Vector2(3, 0))
	
	var attack_highlight := AttackHighlight.instantiate()
		
	attack_highlight.global_position = global_position
	attack_highlight.target = direction * (400 + attack_margin)
	attack_highlight.alpha = 0
	attack_highlight.width = 18
	
	attack_highlight.start_alternate_tween()
	
	fx.add_child(attack_highlight)

func link_poision(ignore_i: int) -> void:
	var i: int = 0
	
	for segment in get_children():
		if i != ignore_i:
			segment.apply_poison(true)
		
		i += 1

func link_health(health: float, caller: Enemy) -> void:
	var to_die: bool = false
	
	for segment: Enemy in get_children():
		segment.health = health
		
		if health <= 0 and segment != caller:
			segment.drop_coins_enabled = false
			segment.die()
			
			to_die = true
	
	if to_die:
		death.emit(Enemy.ID.SNAKE)
		queue_free()
