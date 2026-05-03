extends Node2D

@export var max_health: float = 100
var health: float
var target_health: float

func _ready() -> void:
	health = max_health
	target_health = max_health

func _draw() -> void:
	draw_rect(Rect2(-200, -70, 400, 70), Color(0.2, 0.2, 0.2, 0.4))
	draw_rect(Rect2(-190, -60, 380 * health / max_health, 50), Color(1, 0.3, 0.35))

func _physics_process(_delta: float) -> void:
	health = max(Global.fixed_lerp(health, target_health, 0.2), 0)
	queue_redraw()
