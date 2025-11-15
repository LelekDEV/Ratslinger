extends Area2D

@onready var animation: AnimationPlayer = $AnimationPlayer

var interacting: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interacting = true
		animation.play("enter")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		interacting = false
		animation.play("exit")
