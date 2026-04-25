extends Node2D
class_name SnakeEnemyWrapper

@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var fx: Node2D = get_tree().get_first_node_in_group("fx")
@onready var bossfight_bound: ReferenceRect = get_tree().get_first_node_in_group("bossfight_bound_rect")

var Segment: PackedScene = preload("res://scenes/enemies/snake_enemy_segment.tscn")
var BossSegment: PackedScene = preload("res://scenes/enemies/boss/snake_boss_segment.tscn")

@export var length: int = 20
var speed: float = 150
@export var direction: Vector2 = Vector2.LEFT
var attack_margin: float = 150

var boss_orig_pos: Vector2

var anim_speed: float = 0
var anim_length: float = 22
var anim: float = 0

var leave_tween: Tween
var leave_value: float = 0

var parent: SnakeBoss

# Hand-picked values for offsets:
const BOSS_MARGIN_S = 32 # small
const BOSS_MARGIN_L = 44 # large

# To lazy to write loading system just for this...
# I have joined the preload() cult and it's to late to exit
const BOSS_COLLISIONS = {
	&"h_body": preload("res://scenes/enemies/boss/collision/h_body.tscn"),
	&"h_head": preload("res://scenes/enemies/boss/collision/h_head.tscn"),
	&"v_body": preload("res://scenes/enemies/boss/collision/v_body.tscn"),
	&"v_head_d": preload("res://scenes/enemies/boss/collision/v_head_d.tscn"),
	&"v_head_u": preload("res://scenes/enemies/boss/collision/v_head_u.tscn")
}

enum Type {REGULAR, BOSS_RAPID, BOSS_SPIKED}
@export var type: Type = Type.REGULAR

enum BossMode {IDLE, ATTACK, LEAVE}
var boss_mode = BossMode.IDLE

var connected_boss_wrappers: Array = []

signal death

func _ready() -> void:
	if type == Type.BOSS_RAPID and direction.x == 0:
		anim_length *= 2
	
	for i in range(length):
		var segment: Enemy
		
		match type:
			Type.REGULAR:
				segment = Segment.instantiate()
				
				if i == 0:
					segment.get_node("BaseSprite").play("head")
					segment.get_node("HeadshotArea/CollisionShapeHead").disabled = false
					segment.damage = 2
				else:
					if i == length - 1:
						segment.get_node("BaseSprite").play("tail")
					else:
						segment.get_node("BaseSprite").play("body")
					
					segment.damage = 0.5
					segment.position.x = i * 17 + 3
			
			Type.BOSS_RAPID:
				segment = BossSegment.instantiate()
				var type_name: StringName
				
				if i == 0:
					if direction.y == 0:
						type_name = &"h_head"
					elif direction.y > 0:
						type_name = &"v_head_d"
					else:
						type_name = &"v_head_u"
					
					segment.damage = 2
				else:
					if direction.y == 0:
						type_name = &"h_body"
					else:
						type_name = &"v_body"
						segment.get_node("BaseSprite").flip_h = not i % 2
					
					if direction.y == 0:
						segment.position = Vector2((1 - i) * 22 - 40, 15)
					else:
						segment.position = Vector2(0.5, (1 - i) * 22 - 46)
				
				segment.get_node("BaseSprite").play(type_name)
				
				var collision: Node2D = BOSS_COLLISIONS[type_name].instantiate()
				#collision.z_index = 100
				
				if direction == Vector2.LEFT:
					segment.position.x *= -1
					segment.get_node("BaseSprite").flip_h = true
					
					if type_name == &"h_head":
						# I am pretty sure the bottom line is exactly how it shouldn't be done.
						# The other approach did not work so...
						collision.scale.x *= -1
						collision.position.x *= -1
				
				elif direction == Vector2.UP:
					segment.position.y *= -1
				
				if direction.x == 0:
					segment.is_vertical = true
				
				segment.get_node("HurtArea").add_child(collision)
				if type_name == &"h_body" or type_name == &"v_body":
					segment.add_child(collision.duplicate())
				else:
					segment.get_node("HeadshotArea").add_child(collision.duplicate())
		
		segment.damaged.connect(link_health)
		segment.poison_start.connect(link_poision.bind(i))
		segment.poison_end.connect(link_disable_poison)
		
		if type != Type.REGULAR:
			segment.damaged.connect(parent.update_health)
		
		add_child(segment)
	
	if type == Type.REGULAR:
		attack()
	else:
		attack_boss()

func _physics_process(delta: float) -> void:
	if type == Type.REGULAR:
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
	
	else:
		match boss_mode:
			BossMode.ATTACK:
				if direction.y == 0:
					global_position = boss_orig_pos + Vector2(direction.x * parent.move_value, 0)
				else:
					global_position = boss_orig_pos + Vector2(0, direction.y * parent.move_value)
				
				anim = fmod(anim + anim_speed * delta, anim_length)
				
				if direction.y == 0:
					for segment: Enemy in get_children():
						segment.sprite.offset.x = anim * direction.x
				else:
					for segment: Enemy in get_children():
						segment.sprite.offset.y = anim * direction.y
			
			BossMode.LEAVE:
				speed = parent.speed_value
				global_position += direction * speed * delta
			
			BossMode.IDLE:
				anim_speed = parent.speed_value
				anim = fmod(anim + anim_speed * delta, anim_length)
				
				if direction.y == 0:
					for segment: Enemy in get_children():
						segment.sprite.offset.x = fmod(anim + parent.move_value, anim_length) * direction.x
				else:
					for segment: Enemy in get_children():
						segment.sprite.offset.y = fmod(anim + parent.move_value, anim_length) * direction.y

func apply_offsets(offset: Vector2) -> void:
	for segment: Enemy in get_children():
		segment.fire_fx.position = offset

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

func attack_boss() -> void:
	boss_mode = BossMode.ATTACK
	
	var attack_highlight := AttackHighlight.instantiate()
	
	attack_highlight.alpha = 0
	attack_highlight.width = 28
	
	if direction.y == 0:
		global_position.y = player.global_position.y
		global_position.x = direction.x * (-bossfight_bound.size.x / 2 - BOSS_MARGIN_S)
		attack_highlight.target = Vector2(direction.x * (bossfight_bound.size.x + BOSS_MARGIN_S), 0)
	else:
		global_position.x = player.global_position.x
		global_position.y = direction.y * (-bossfight_bound.size.y / 2 - BOSS_MARGIN_L)
		attack_highlight.target = Vector2(0, direction.y * (bossfight_bound.size.y + BOSS_MARGIN_L))
	
	boss_orig_pos = global_position
	
	attack_highlight.global_position = global_position
	attack_highlight.start_alternate_tween()
	
	fx.add_child(attack_highlight)
	
	await get_tree().create_timer(1.2, false).timeout
	
	parent.move_tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUINT)
	
	if direction.y == 0:
		parent.move_tween.tween_property(parent, "move_value", bossfight_bound.size.x + BOSS_MARGIN_S * 2, 1.5)
	else:
		parent.move_tween.tween_property(parent, "move_value", bossfight_bound.size.y + BOSS_MARGIN_S + BOSS_MARGIN_L, 1.5)
	
	parent.move_tween.tween_callback(parent.end_move)
	parent.move_tween.tween_callback(set.bind("boss_mode", BossMode.IDLE))
	
	await get_tree().create_timer(0.5, false).timeout
	anim_speed = 50

func leave_boss() -> void:
	if direction.y == 0:
		global_position.x += anim * direction.x
	else:
		global_position.y += anim * direction.y
	
	for segment: Enemy in get_children():
		segment.sprite.offset = Vector2.ZERO
	
	anim_speed = 0
	anim = 0
	boss_mode = BossMode.LEAVE

func link_boss(wrappers: Array) -> void:
	for wrapper: SnakeEnemyWrapper in wrappers:
		if not wrapper in connected_boss_wrappers and wrapper != self:
			for segment: Enemy in wrapper.get_children():
				segment.damaged.connect(link_health)
				segment.poison_start.connect(link_poision.bind(-1))
				segment.poison_end.connect(link_disable_poison)
			
			connected_boss_wrappers.append(wrapper)

func link_disable_poison() -> void:
	for segment: Enemy in get_children():
		segment.disable_poison()

func link_poision(ignore_i: int) -> void:
	var i: int = 0
	
	for segment: Enemy in get_children():
		if i != ignore_i:
			segment.apply_poison(true)
		
		i += 1

func link_health(health: float, caller: Enemy, _projectile: Projectile = null) -> void:
	if caller.to_die:
		return
	
	var to_die: bool = false
	
	for segment: Enemy in get_children():
		segment.health = health
		
		if health <= 0 and segment != caller:
			segment.drop_coins_enabled = false
			segment.to_die = true
			
			segment.die()
			
			to_die = true
	
	if to_die and not type in [Type.BOSS_RAPID, Type.BOSS_SPIKED]:
		death.emit(Enemy.ID.SNAKE)
		queue_free()
