extends StaticBody2D

@onready var shop_layer: CanvasLayer = get_tree().get_first_node_in_group("shop_layer")
@onready var interaction_area: Area2D = $InteractionArea

func _physics_process(_delta: float) -> void:
	if interaction_area.interacting and Input.is_action_just_pressed("interact"):
		shop_layer.enter()
