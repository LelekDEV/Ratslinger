@tool
extends Path2D

func _draw() -> void:
	var points: Array = Array(curve.get_baked_points())
	const WIDTH: float = 30
	
	draw_polyline(points.map(func(point: Vector2): return point + Vector2(1, 1)), Consts.RIVER_COLOR_DARK, WIDTH)
	draw_polyline(points.map(func(point: Vector2): return point + Vector2(-1, -1)), Consts.RIVER_COLOR_DARK, WIDTH)
	draw_polyline(points.map(func(point: Vector2): return point + Vector2(-1, 1)), Consts.RIVER_COLOR_DARK, WIDTH)
	draw_polyline(points.map(func(point: Vector2): return point + Vector2(1, -1)), Consts.RIVER_COLOR_DARK, WIDTH)
	
	draw_polyline(points, Consts.RIVER_COLOR_LIGHT, WIDTH)
