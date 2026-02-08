extends Node2D

@onready var SplashFX: PackedScene = preload("res://scenes/fx/splash_fx.tscn")

var points: Dictionary

var surface_size: Vector2

var spawn_value: float = 0
var spawn_treshold: float = 0.1

func _draw() -> void:
	"""for pos in points.top:
		draw_circle(pos - floor(surface_size / 2), 0.5, Color.RED)
	
	for pos in points.side:
		draw_circle(pos - floor(surface_size / 2), 0.5, Color.DARK_TURQUOISE)"""

func _physics_process(delta: float) -> void:
	spawn_value += delta * Global.get_rain_change_ratio()
	
	if spawn_value > spawn_treshold:
		var fx: AnimatedSprite2D = SplashFX.instantiate()
		
		var pos: Vector2
		
		if randf_range(0, 1) > 0.2:
			pos = points.top[randi_range(0, points.top.size() - 1)]
		else:
			pos = points.side[randi_range(0, points.side.size() - 1)]
		
		fx.position = pos - floor(surface_size / 2)
		
		add_child(fx)
		
		spawn_value = 0
		spawn_treshold = randf_range(0.08, 0.1)
