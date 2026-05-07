@tool
extends Node

@export var parent: AccuracyBar
@export var sprite: Sprite2D

@export_tool_button("Update texture") var update_action = update_texture

const SIZE := Vector2i(77, 15)

const ATLAS: Dictionary = {
	"ry": Rect2i(0, 0, 5, 15),
	"yg": Rect2i(6, 0, 5, 15),
	"rg": Rect2i(12, 0, 5, 15),
	"r": Rect2i(0, 16, 1, 15),
	"y": Rect2i(2, 16, 1, 15),
	"g": Rect2i(4, 16, 1, 15),
}

func _ready() -> void:
	update_texture()

func update_texture() -> void:
	sprite.texture = generate(parent.accuracy_tresholds)

func generate(accuracy_tresholds: Array) -> Texture2D:
	var src: Image = preload("res://graphics/ui/hud/combat/accuracy_zones.png").get_image()
	var img := Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	
	var last_v: float = 0
	for treshold in accuracy_tresholds:
		for x in range(round(last_v * SIZE.x), round(treshold.v * SIZE.x)):
			img.blend_rect(src, [ATLAS.r, ATLAS.y, ATLAS.g][treshold.t], Vector2i(x, 0))
		last_v = treshold.v
	
	for i in range(accuracy_tresholds.size() - 1):
		var t_start: Dictionary = accuracy_tresholds[i]
		var t_end: Dictionary = accuracy_tresholds[i + 1]
		var rect: Rect2i
		var flip: bool = false
		
		# That kinda hurts, not gonna lie
		if t_start.t == 0 and t_end.t == 1:
			rect = ATLAS.ry
		elif t_start.t == 1 and t_end.t == 2:
			rect = ATLAS.yg
		elif t_start.t == 0 and t_end.t == 2:
			rect = ATLAS.rg
		elif t_start.t == 1 and t_end.t == 0:
			rect = ATLAS.ry
			flip = true
		elif t_start.t == 2 and t_end.t == 1:
			rect = ATLAS.yg
			flip = true
		elif t_start.t == 2 and t_end.t == 0:
			rect = ATLAS.rg
			flip = true
		
		var sub_img: Image = src.get_region(rect)
		if flip: sub_img.flip_x()
		
		img.blend_rect(
			sub_img, 
			Rect2i(Vector2i.ZERO, sub_img.get_size()), 
			Vector2i(round(t_start.v * SIZE.x) - 3 + int(flip), 0)
		)
	
	return ImageTexture.create_from_image(img)
