extends Node2D
class_name SnakeBoss

@onready var enemies: Node2D = get_tree().get_first_node_in_group("enemies")
@onready var boss_healthbar: Node2D = get_tree().get_first_node_in_group("boss_healthbar")

var move_tween: Tween
var move_value: float = 0

var wrappers: Array
var last_dir: Vector2

var speed_tween: Tween
var speed_value: float = 50

var max_health: float = 100
var health: float = max_health

var is_attacking: bool = true

func _ready() -> void:
	await get_tree().create_timer(2, false).timeout
	is_attacking = false

func _physics_process(_delta: float) -> void:
	if not is_attacking:
		rapid_attack(int((1 - health / max_health) * 3 + 3))
	
	boss_healthbar.target_health = health

func rapid_attack(count: int) -> void:
	is_attacking = true
	move_value = 0
	speed_value = 50
	last_dir = Vector2.ZERO
	
	for i in range(count):
		var wrapper: SnakeEnemyWrapper = preload("res://scenes/enemies/snake_enemy_wrapper.tscn").instantiate()
		var dir_roll: int
		
		if last_dir in [Vector2.LEFT, Vector2.RIGHT]:
			dir_roll = randi_range(2, 3)
		elif last_dir in [Vector2.DOWN, Vector2.UP]:
			dir_roll = randi_range(0, 1)
		else:
			dir_roll = randi_range(0, 3)
		
		wrapper.type = SnakeEnemyWrapper.Type.BOSS_RAPID
		wrapper.speed = 50
		wrapper.parent = self
		
		if dir_roll < 2:
			wrapper.length = 22
			wrapper.direction = Vector2.RIGHT if dir_roll == 0 else Vector2.LEFT
		else:
			wrapper.length = 16
			wrapper.direction = Vector2.DOWN if dir_roll == 2 else Vector2.UP
		
		wrappers.append(wrapper)
		enemies.add_child(wrapper)
		
		# This get's a reference segment for obtaining info like ~~health~~ and posion
		# Absolutely not the greatest idea but the quickest with the current structure :P
		var ref_seg: Enemy = wrappers[0].get_child(0)
		
		for _wrapper: SnakeEnemyWrapper in wrappers:
			_wrapper.link_boss(wrappers)
			
			for segment: Enemy in _wrapper.get_children():
				segment.health = health
				if ref_seg.poison_value != 0 and segment.poison_value == 0:
					segment.apply_poison(true)
		
		last_dir = wrapper.direction
		await get_tree().create_timer(3, false).timeout
	
	await get_tree().create_timer(1, false).timeout
	
	speed_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	
	speed_tween.tween_property(self, "speed_value", 500, 5)
	
	var i: int = 0
	for wrapper: SnakeEnemyWrapper in wrappers:
		wrapper.leave_boss()
		# I am genuinely to lazy to account for the grand total of TWO possible cases
		# and make it have just-nice interval values.
		# Instead take this piece of brute-forced just-works formula
		await get_tree().create_timer(max(3 - i * 1.5, 1), false).timeout
		i += 1
	
	free_segments()
	
	await get_tree().create_timer(1, false).timeout
	is_attacking = false

func end_move() -> void:
	for wrapper: SnakeEnemyWrapper in wrappers:
		if wrapper.boss_mode == SnakeEnemyWrapper.BossMode.IDLE:
			wrapper.anim = fmod(wrapper.anim + move_value, wrapper.anim_length)
	
	move_value = 0

func free_segments() -> void:
	for wrapper: SnakeEnemyWrapper in wrappers:
		wrapper.queue_free()
	wrappers.clear()

func update_health(value: float, _caller: Enemy, projectile: Projectile = null) -> void:
	health = value
	
	if value <= 0:
		SignalBus.boss_death.emit(projectile)
		GlobalAudio.play_sfx(AudioConsts.SFX.BOSS_DEATH, 0, 0.65)
		
		await SignalBus.boss_death_anim_ended
		
		Global.game.end_wave()
		boss_healthbar.target_health = 0
		
		free_segments()
		queue_free()
