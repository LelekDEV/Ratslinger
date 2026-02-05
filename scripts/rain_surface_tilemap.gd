extends TileMapLayer

@onready var RainSurfaceTile: PackedScene = preload("res://scenes/rain_surface_tile.tscn")

@export var spawn_node: Node

func _ready() -> void:
	for cell in get_used_cells():
		var data: TileData = get_cell_tile_data(cell)
		
		if data == null:
			continue
		
		if not data.has_custom_data("rain_points"):
			continue
		
		var surface: Node2D = RainSurfaceTile.instantiate()
		
		surface.points = data.get_custom_data("rain_points")
		surface.surface_size = data.get_custom_data("size")
		surface.position = map_to_local(cell)
		
		spawn_node.add_child(surface)
