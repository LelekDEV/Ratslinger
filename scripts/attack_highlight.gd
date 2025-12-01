extends Node2D
class_name AttackHighlight

static func instantiate() -> AttackHighlight:
	return preload("res://scenes/attack_highlight.tscn").instantiate() as AttackHighlight

@export var color: Color

var target: Vector2
var alpha: float = 1
var width: float = 10

var decay_tween: Tween

func _physics_process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2.ZERO, target, Color(color.r, color.b, color.b, color.a * alpha), width)
