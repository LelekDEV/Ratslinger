extends Node2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var interaction_area: Area2D = $InteractionArea

@onready var markers: Node2D = get_tree().get_first_node_in_group("markers")

func _physics_process(_delta: float) -> void:
	if interaction_area.interacting and Input.is_action_just_pressed("interact"):
		player.location = player.Locations.TOWN
		player.global_position = markers.points.rat_house_exit_pos
		
