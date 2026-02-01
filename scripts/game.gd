extends Node2D
class_name Game

@onready var FoxEnemy: PackedScene = preload("res://scenes/enemies/fox_enemy.tscn")
@onready var BeaverEnemy: PackedScene = preload("res://scenes/enemies/beaver_enemy.tscn")
@onready var SnakeEnemy: PackedScene = preload("res://scenes/enemies/snake_enemy_wrapper.tscn")

@onready var ui: UI = $UI

@onready var enemies: Node = $Enemies

@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var crosshair: Sprite2D = $UI/Crosshair

@onready var player_death_handler: Node = $PlayerDeathHandler
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer

@onready var gate: StaticBody2D = $Buildings/Gate
@onready var wave_start_interaction_area: Area2D = $WaveStartInteractionArea

var enemies_total: int = 5
var enemies_to_spawn: int = enemies_total
var enemies_killed: int = 0

var is_wave_active: bool = false
var waves_cleared: int = 0

func _ready() -> void:
	setup_signals()
	Global.game = self
	
	"""update_enemies(5)
	enemies_to_spawn = 0
	for enemy: Enemy in enemies.get_children(): enemy.queue_free()"""

func _physics_process(_delta: float) -> void:
	if wave_start_interaction_area.interacting and Input.is_action_just_pressed("interact") and not is_wave_active:
		start_wave()

func start_wave() -> void:
	gate.get_node("LockSprite").self_modulate.a = 1
	gate.get_node("CollisionShape2D").set_deferred("disabled", false)
	
	ui.animation.play("wave_start")
	
	enemies_total = 5 + waves_cleared
	enemies_to_spawn = enemies_total
	enemies_killed = 0
	
	spawn_enemy()
	ui.update_enemy_count(0, enemies_total)
	
	enemy_spawn_timer.wait_time = max(round((8 - log(waves_cleared + 1)) * 100) / 100, 0.5)
	enemy_spawn_timer.start()
	
	print("Wave %s started, enemy count: %s, spawn inteval: %s" % [
		waves_cleared + 1, 
		enemies_total,
		enemy_spawn_timer.wait_time
	])
	
	is_wave_active = true
	wave_start_interaction_area.visible = false

func end_wave() -> void:
	gate.get_node("AnimationPlayer2").play("unlock")
	gate.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	ui.animation.play("wave_end")
	
	ui.update_enemy_count(-1)
	
	is_wave_active = false
	wave_start_interaction_area.visible = true
	waves_cleared += 1

func setup_signals() -> void:
	SignalBus.player_shoot.connect(camera.shake)
	SignalBus.player_shoot.connect(crosshair.on_player_shoot)
	
	SignalBus.player_death.connect(player_death_handler.on_player_death)
	
	SignalBus.player_location_change.connect(ui.on_player_location_change)
	SignalBus.player_location_change.connect(on_player_location_change)
	
	SignalBus.player_hit.connect(ui.animation.play.bind("player_hit"))
	SignalBus.player_hit.connect(camera.shake)

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
func update_enemies(killed_id: Enemy.ID = -1, killed_amount: int = 1) -> void:
	enemies_killed += killed_amount
	
	if killed_id == Global.mission_target:
		Global.mission_killed += killed_amount
	
	ui.update_enemy_count(enemies_killed, enemies_total)
	
	if enemies_killed >= enemies_total:
		end_wave()

func spawn_enemy() -> void:
	if enemies_to_spawn <= 0:
		return
	
	var enemy_roll: float = randf_range(0, 1)
	
	if enemy_roll > 0.2:
		var enemy: Enemy = FoxEnemy.instantiate() if enemy_roll > 0.5 else BeaverEnemy.instantiate()
		
		if randi_range(0, 1) == 0:
			if randi_range(0, 1) == 0:
				enemy.global_position.x = -364
				enemy.global_position.y = randi_range(100, 264) * -1 if randi_range(0, 1) == 0 else 1
			else:
				enemy.global_position.x = 364
				enemy.global_position.y = randi_range(-264, 264)
		else:
			enemy.global_position.x = randi_range(-364, 364)
			enemy.global_position.y = -264 if randi_range(0, 1) == 0 else 264
		
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	else:
		var enemy: SnakeEnemyWrapper = SnakeEnemy.instantiate()
		
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	enemies_to_spawn -= 1

func on_player_location_change(_location: Player.Locations) -> void:
	"""if location == Player.Locations.ARENA:
		enemy_spawn_timer.paused = false
		enemies.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		enemy_spawn_timer.paused = true
		enemies.process_mode = Node.PROCESS_MODE_DISABLED"""

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
