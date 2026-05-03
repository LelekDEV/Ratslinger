extends Sprite2D
class_name RainSurfaceSprite

@onready var SplashFX: PackedScene = preload("res://scenes/fx/weather/splash_fx.tscn")

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
	update_data()

func update_data() -> void:
	if hframes > 1 or vframes > 1:
		var img: Image = texture.get_image()
		
		@warning_ignore("integer_division")
		img = img.get_region(Rect2i(
			frame_coords.x * texture.get_width() / hframes,
			frame_coords.y * texture.get_height() / vframes,
			texture.get_width() / hframes,
			texture.get_height() / vframes
		))
		
		var cropped_tex = ImageTexture.create_from_image(img)
		
		points = RainSurface.get_edges(cropped_tex)
		surface_size = cropped_tex.get_size()
	
	else:
		points = RainSurface.get_edges(texture)
		surface_size = texture.get_size()

func _physics_process(delta: float) -> void:
	spawn_value += delta * Global.get_rain_change_ratio()
	
	if spawn_value > spawn_treshold:
		var fx: AnimatedSprite2D = SplashFX.instantiate()
		
		var pos: Vector2
		
		if randf_range(0, 1) > 0.2:
			pos = points.top[randi_range(0, points.top.size() - 1)] + offset
		else:
			pos = points.side[randi_range(0, points.side.size() - 1)] + offset
		
		if use_meta:
			fx.set_meta("flippable_pos", pos)
			fx.visible = false
		else:
			fx.position = pos - floor(surface_size / 2)
		
		spawn_node.add_child(fx)
		
		spawn_value = 0
		spawn_treshold = randf_range(0.08, 0.1) * treshold_mod
