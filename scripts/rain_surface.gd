extends AnimatedSprite2D

@onready var SplashFX: PackedScene = preload("res://scenes/fx/splash_fx.tscn")

var frame_points: Array

var spawn_value: float = 0
var spawn_treshold: float = 0.1
var spawn_node: Node

func _draw() -> void:
	"""for pos in frame_points[frame].top:
		if flip_h:
			draw_circle((pos - floor(Vector2(37, 32) / 2)) * Vector2(-1, 1), 0.5, Color.RED)
		else:
			draw_circle(pos - floor(Vector2(37, 32) / 2), 0.5, Color.RED)
	
	for pos in frame_points[frame].side:
		if flip_h:
			draw_circle((pos - floor(Vector2(37, 32) / 2)) * Vector2(-1, 1), 0.5, Color.DARK_TURQUOISE)
		else:
			draw_circle(pos - floor(Vector2(37, 32) / 2), 0.5, Color.DARK_TURQUOISE)"""

func _ready() -> void:
	get_all_points()

func _physics_process(delta: float) -> void:
	spawn_value += delta
	
	if spawn_value > spawn_treshold:
		var fx: AnimatedSprite2D = SplashFX.instantiate()
		
		var pos: Vector2
		
		if randf_range(0, 1) > 0.2:
			pos = frame_points[frame].top[randi_range(0, frame_points[frame].top.size() - 1)]
		else:
			pos = frame_points[frame].side[randi_range(0, frame_points[frame].side.size() - 1)]
		
		fx.set_meta("flippable_pos", pos)
		fx.visible = false
		
		spawn_node.add_child(fx)
		
		spawn_value = 0
		spawn_treshold = randf_range(0.08, 0.1)

func get_all_points() -> void:
	var frames = sprite_frames
	var anim = animation
	var count = frames.get_frame_count(anim)
	
	for i in range(count):
		var texture = frames.get_frame_texture(anim, i)
		frame_points.append(get_edges(texture))

func get_edges(texture: Texture2D) -> Dictionary:
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
