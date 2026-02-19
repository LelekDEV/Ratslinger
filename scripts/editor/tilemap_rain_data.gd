@tool
extends EditorScript

# EDITOR SCRIPT: used to calculate splash points on tileset sprites
# ctrl + shift + x to update
func _run() -> void:
	var tileset: TileSet = load("res://data/environment_tileset.tres")
	
	for i in range(tileset.get_source_count()):
		var source: TileSetSource = tileset.get_source(i)
		
		if not source is TileSetAtlasSource:
			continue
		
		var atlas := source as TileSetAtlasSource
		
		for j in atlas.get_tiles_count():
			var coords: Vector2i = atlas.get_tile_id(j)
			
			for id in atlas.get_alternative_tiles_count(coords):
				var data: TileData = atlas.get_tile_data(coords, id)
				var region: Rect2i = atlas.get_tile_texture_region(coords)
				
				var texture := AtlasTexture.new()
				texture.set_atlas(atlas.texture)
				texture.set_region(region)
				
				var points: Dictionary = RainSurface.get_edges(texture)
				
				data.set_custom_data("rain_points", points)
				data.set_custom_data("size", region.size)
	
	ResourceSaver.save(tileset)
	print("Tilemap data has been updated")
