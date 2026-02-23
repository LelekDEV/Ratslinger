extends Node2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var markers: Node2D = get_tree().get_first_node_in_group("markers")
@onready var weather_layer: CanvasLayer = get_tree().get_first_node_in_group("weather_layer")

@onready var interaction_area: Area2D = $InteractionArea

func _physics_process(_delta: float) -> void:
	if interaction_area.interacting and Input.is_action_just_pressed("interact"):
		player.location = player.Locations.TOWN
		player.global_position = markers.points.rat_house_exit_pos
		
		weather_layer.visible = true
		player.local_fx.visible = true
