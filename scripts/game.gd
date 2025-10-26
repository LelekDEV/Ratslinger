extends Node2D

@onready var _Enemy: PackedScene = preload("res://scenes/enemies/fox_enemy.tscn")

@onready var ui: CanvasLayer = $UI

@onready var enemies: Node = $Enemies

@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var crosshair: Sprite2D = $Crosshair

@onready var player_death_handler: Node = $PlayerDeathHandler

func _ready() -> void:
	SignalBus.player_shoot.connect(camera.shake)
	SignalBus.player_shoot.connect(crosshair.on_player_shoot)
	SignalBus.player_death.connect(player_death_handler.on_player_death)
	SignalBus.player_location_change.connect(ui.on_player_location_change)
	SignalBus.player_hit.connect(ui.animation.play.bind("player_hit"))
	SignalBus.player_hit.connect(camera.shake)

func _on_enemy_spawn_timer_timeout() -> void:
	var enemy: Enemy = _Enemy.instantiate()
	
	if randi_range(0, 2) == 0:
		enemy.global_position.x = 364
		enemy.global_position.y = randi_range(-264, 264)
	else:
		enemy.global_position.x = randi_range(-364, 364)
		enemy.global_position.y = -264 if randi_range(0, 1) == 0 else 264
	
	enemies.add_child(enemy)
