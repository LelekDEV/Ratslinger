extends Node2D

@onready var player: Player = get_tree().get_first_node_in_group("player")

@export var draw_curve: Curve
@export var root: Node2D

var start_pos: Vector2

var point_count: int = 100
var points: Array = []
var dir: Vector2 = Vector2.DOWN

var turn_time: float = 1

var speed: float = 45

var update_progress: float = 0
var update_fps: float = 30

func _ready() -> void:
	for i in range(point_count):
		points.append(start_pos)

func _draw() -> void:
	var i: int = 0
	for p in points:
		draw_circle(p + Vector2.ONE * 256 - points[0], 6 * draw_curve.sample(i / float(point_count)), Color("#7ec758"))
		i += 1

func _physics_process(delta: float) -> void:
	turn_time -= delta
	
	if turn_time <= 0:
		if dir.y == 0:
			dir = Vector2i.DOWN if root.global_position.y < player.global_position.y else Vector2i.UP
		else:
			dir = Vector2i.RIGHT if root.global_position.x < player.global_position.x else Vector2i.LEFT
		
		turn_time = randf_range(0.5, 1) / 2 + fmod(turn_time, 1)
	
	while update_progress >= 1 / update_fps:
		var offset: Vector2 = dir * speed * (1 / update_fps)
		const STEPS: int = 4
		
		for i in range(STEPS):
			points.push_front(points[0] + offset * (i + 1) / float(STEPS))
			points.pop_back()
		
		root.global_position = points[0]
		
		queue_redraw()
		
		update_progress -= 1 / update_fps
	
	update_progress += delta
