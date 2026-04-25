extends Node2D

@onready var Spike: PackedScene = preload("res://scenes/sand_spike.tscn")

@onready var bossfight_bound: ReferenceRect = get_tree().get_first_node_in_group("bossfight_bound_rect")

func _ready() -> void:
	var h_size: Vector2 = bossfight_bound.size / 2
	
	for x in range(-h_size.x, h_size.x, 30):
		for y in [-h_size.y + 15, h_size.y - 15]:
			var spike: SandSpike = Spike.instantiate()
			
			spike.global_position = Vector2(x + 15 + randf_range(-4, 4), y + randf_range(-4, 4))
			spike.order_value = spike.global_position.distance_to(-h_size)
			
			spike.get_node("ColorRect/Sprite2D").frame = randi_range(0, 2)
			spike.get_node("ColorRect/Sprite2D").flip_h = randi_range(0, 1)
			spike.get_node("ColorRect/Sprite2D").update_data()
			
			add_child(spike)
	
	for y in range(-h_size.y + 30, h_size.y - 30, 32):
		for x in [-h_size.x + 15, h_size.x - 15]:
			var spike: SandSpike = Spike.instantiate()
			
			spike.global_position = Vector2(x + randf_range(-4, 4), y + 13 + randf_range(-4, 4))
			spike.order_value = spike.global_position.distance_to(-h_size)
			
			spike.get_node("ColorRect/Sprite2D").frame = randi_range(0, 2)
			spike.get_node("ColorRect/Sprite2D").flip_h = randi_range(0, 1)
			spike.get_node("ColorRect/Sprite2D").update_data()
			
			add_child(spike)
