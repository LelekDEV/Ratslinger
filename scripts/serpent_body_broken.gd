# This approach resulted in various jitters and blurs when drawing.
# Keeping it just in case

extends Node2D

@onready var player: Player = get_tree().get_first_node_in_group("player")

@export var draw_curve: Curve
@export var root: Node2D

const total_length: float = 70
var lengths: Array = [total_length]
var dirs: Array = [Vector2i.UP]

const draw_precision: float = 50

var turn_time: float = 1

var speed: float = 95
var turn_margin: float = 20

func _draw() -> void:
	var pos = Vector2.ONE * 256
	var dist: float = 0
	
	for i in range(lengths.size()):
		var l: float = lengths[i]
		var d: Vector2 = dirs[i]
		
		var old_pos: Vector2 = pos
		pos += (l * d).round()
		
		for t in range(0, draw_precision, 1):
			draw_circle(lerp(old_pos, pos, t / draw_precision), 6 * draw_curve.sample(dist / total_length), Color("#7ec758"))
			dist += l / draw_precision
		
		draw_line(old_pos, pos, Color.RED)

func _physics_process(delta: float) -> void:
	turn_time -= delta
	
	if turn_time <= 0:
		if dirs[0].y == 0:
			dirs.push_front(Vector2i.DOWN if root.global_position.y > player.global_position.y else Vector2i.UP)
		else:
			dirs.push_front(Vector2i.RIGHT if root.global_position.x > player.global_position.x else Vector2i.LEFT)
		
		lengths.push_front(0)
		turn_time = randf_range(0.5, 1) / 2 + fmod(turn_time, 1)
	
	lengths[-1] -= delta * speed
	lengths[0] += delta * speed
	
	if lengths[-1] <= 0:
		#lengths[0] -= lengths[-1]
		lengths.remove_at(-1)
		dirs.remove_at(-1)
	
	root.global_position -= dirs[0] * delta * speed
	
	queue_redraw()
