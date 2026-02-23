extends Sprite2D
class_name RainSurfaceSprite

@onready var SplashFX: PackedScene = preload("res://scenes/fx/splash_fx.tscn")

var points: Dictionary
var surface_size: Vector2

@export var treshold_mod: float = 1
@export var use_meta: bool

var spawn_value: float = 0
var spawn_treshold: float = 0.1
@export var spawn_node: Node

func _draw() -> void:
	"""for pos in points.top:
		if flip_h:
			draw_circle((pos - floor(surface_size / 2)) * Vector2(-1, 1), 0.5, Color.RED)
		else:
			draw_circle(pos - floor(surface_size / 2), 0.5, Color.RED)
	
	for pos in points.side:
		if flip_h:
			draw_circle((pos - floor(surface_size / 2)) * Vector2(-1, 1), 0.5, Color.DARK_TURQUOISE)
		else:
			draw_circle(pos - floor(surface_size / 2), 0.5, Color.DARK_TURQUOISE)"""

func _ready() -> void:
	points = RainSurface.get_edges(texture)
	surface_size = Vector2(texture.get_width(), texture.get_height())

func _physics_process(delta: float) -> void:
	spawn_value += delta * Global.get_rain_change_ratio()
	
	if spawn_value > spawn_treshold:
		var fx: AnimatedSprite2D = SplashFX.instantiate()
		
		var pos: Vector2
		
		if randf_range(0, 1) > 0.2:
			pos = points.top[randi_range(0, points.top.size() - 1)]
		else:
			pos = points.side[randi_range(0, points.side.size() - 1)]
		
		if use_meta:
			fx.set_meta("flippable_pos", pos)
			fx.visible = false
		else:
			fx.position = pos - floor(surface_size / 2)
		
		spawn_node.add_child(fx)
		
		spawn_value = 0
		spawn_treshold = randf_range(0.08, 0.1) * treshold_mod
