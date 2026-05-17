extends AnimatedSprite2D
class_name RainSurface

@onready var SplashFX: PackedScene = preload("res://scenes/fx/weather/splash_fx.tscn")

var all_points: Dictionary
var surface_size: Vector2

@export var use_meta: bool

var spawn_value: float = 0
var spawn_treshold: float = 0.1
@export var spawn_node: Node

func _ready() -> void:
	get_all_points()
	
	var first_texture = sprite_frames.get_frame_texture(animation, 0)
	surface_size = Vector2(first_texture.get_width(), first_texture.get_height())

# DEBUG SPLASH POINTS DRAW
"""func _draw() -> void:
	for pos in all_points[animation][frame].top:
		draw_circle(pos - surface_size / 2 + spawn_node.position, 0.25, Color.RED)"""

func _physics_process(delta: float) -> void:
	spawn_value += delta * Global.get_rain_change_ratio()
	
	if spawn_value > spawn_treshold:
		var fx: AnimatedSprite2D = SplashFX.instantiate()
		
		var pos: Vector2
		
		if randf_range(0, 1) > 0.2:
			pos = all_points[animation][frame].top[randi_range(0, all_points[animation][frame].top.size() - 1)]
		else:
			pos = all_points[animation][frame].side[randi_range(0, all_points[animation][frame].side.size() - 1)]
		
		if use_meta:
			fx.set_meta("flippable_pos", pos)
			fx.visible = false
		else:
			fx.position = pos - surface_size / 2
		
		spawn_node.add_child(fx)
		
		spawn_value = 0
		spawn_treshold = randf_range(0.08, 0.1)

func get_all_points() -> void:
	for anim in sprite_frames.get_animation_names():
		all_points[anim] = []
		
		for i in range(sprite_frames.get_frame_count(anim)):
			var texture = sprite_frames.get_frame_texture(anim, i)
			all_points[anim].append(get_edges(texture))

static func get_edges(texture: Texture2D) -> Dictionary:
	var points: Dictionary = {
		"top": [], "side": []
	}
	
	var img: Image = texture.get_image()
	var width: int = img.get_width()
	var height: int = img.get_height()
	
	# top edge
	for x in range(width):
		for y in range(height):
			if img.get_pixel(x, y).a != 0:
				points.top.append(Vector2(x, y))
				break
	
	# left edge
	for y in range(height):
		for x in range(width):
			if img.get_pixel(x, y).a != 0:
				if not Vector2(x, y) in points.top:
					points.side.append(Vector2(x, y))
				break
	
	# right edge
	for y in range(height):
		for x in range(width - 1, -1, -1):
			if img.get_pixel(x, y).a != 0:
				if not Vector2(x, y) in points.top and not Vector2(x, y) in points.side:
					points.side.append(Vector2(x, y))
				break
	
	return points
