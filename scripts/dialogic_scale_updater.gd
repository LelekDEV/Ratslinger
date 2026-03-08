extends Node

@onready var target: Control

func _ready() -> void:
	target = get_parent()

func _physics_process(_delta: float) -> void:
	target.scale = Vector2.ONE * (Global.scale_level + 4) / 4
	target.size = get_viewport().get_visible_rect().size / target.scale
