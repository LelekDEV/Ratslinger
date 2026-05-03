extends Node2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var bestiary_layer: CanvasLayer = get_tree().get_first_node_in_group("bestiary_layer")

func _physics_process(_delta: float) -> void:
	if interaction_area.interacting and Input.is_action_just_pressed("interact"):
		bestiary_layer.enter()
