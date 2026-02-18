extends Node2D

var points: Dictionary = {}

func _ready() -> void:
	for marker in get_children():
		points[marker.name.to_snake_case()] = marker.global_position
