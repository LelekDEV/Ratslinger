extends Node2D

@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var crosshair: Sprite2D = $Crosshair

func _ready() -> void:
	SignalBus.player_shoot.connect(camera.on_player_shoot)
	SignalBus.player_shoot.connect(crosshair.on_player_shoot)
