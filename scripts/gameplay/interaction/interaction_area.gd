extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

@export var pos_value: float
@export var direction := Vector2(0, -1)

var interacting: bool = false

func _process(_delta: float) -> void:
	sprite.position = direction * pos_value

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interacting = true
		animation.play("enter")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		interacting = false
		animation.play("exit")
