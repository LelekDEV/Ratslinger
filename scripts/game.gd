extends Node2D

@onready var _Enemy: PackedScene = preload("res://scenes/enemies/fox_enemy.tscn")

@onready var ui: CanvasLayer = $UI

@onready var enemies: Node = $Enemies

@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var crosshair: Sprite2D = $Crosshair

@onready var player_death_handler: Node = $PlayerDeathHandler
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer

@onready var gate: StaticBody2D = $Gate

var enemies_to_spawn: int = 5
var enemies_killed: int = 0

func _ready() -> void:
	setup_signals()
	spawn_enemy()
	
	"""update_enemies(5)
	enemies_to_spawn = 0
	for enemy: Enemy in enemies.get_children(): enemy.queue_free()"""

func setup_signals() -> void:
	SignalBus.player_shoot.connect(camera.shake)
	SignalBus.player_shoot.connect(crosshair.on_player_shoot)
	
	SignalBus.player_death.connect(player_death_handler.on_player_death)
	
	SignalBus.player_location_change.connect(ui.on_player_location_change)
	SignalBus.player_location_change.connect(on_player_location_change)
	
	SignalBus.player_hit.connect(ui.animation1.play.bind("player_hit"))
	SignalBus.player_hit.connect(camera.shake)

func update_enemies(killed_amount: int = 1) -> void:
	enemies_killed += killed_amount
	ui.update_enemy_count(enemies_killed)
	
	if enemies_killed >= 5:
		gate.get_node("AnimationPlayer2").play("unlock")
		gate.get_node("CollisionShape2D").set_deferred("disabled", true)
		
		ui.animation2.play("wave_cleared")

func spawn_enemy() -> void:
	if enemies_to_spawn <= 0:
		return
	
	var enemy: Enemy = _Enemy.instantiate()
	
	if randi_range(0, 2) == 0:
		enemy.global_position.x = 364
		enemy.global_position.y = randi_range(-264, 264)
	else:
		enemy.global_position.x = randi_range(-364, 364)
		enemy.global_position.y = -264 if randi_range(0, 1) == 0 else 264
	
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
