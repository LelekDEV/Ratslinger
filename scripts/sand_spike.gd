extends Node2D
class_name SandSpike

@onready var sprite: Sprite2D = $ColorRect/Sprite2D
@onready var particles: GPUParticles2D = $CPUParticles2D
@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

var appear_tween: Tween
var appear_value: float = 0

var order_value: float

func _physics_process(_delta: float) -> void:
	sprite.offset.y = floor((1 - appear_value) * 20)
	particles.emitting = appear_value != 1 and appear_value != 0

func reset() -> void:
	appear_value = 0
	sprite.offset.y = 20

func appear(wait_time: float = 0) -> void:
	await get_tree().create_timer(wait_time, false).timeout
	
	appear_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	
	appear_tween.tween_property(self, "appear_value", 1, 1.5)
