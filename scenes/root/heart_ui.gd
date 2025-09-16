extends Node2D

@export var segments_per_heart := 5
@export var drain_right_first := true    # żeby przy -4 HP zmieniało się tylko prawe serce

@onready var heart: AnimatedSprite2D = $Heart


var max_hp := 10

func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
					
