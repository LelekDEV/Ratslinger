extends CanvasLayer

@onready var base_sprite: Sprite2D = $BaseSprite
@onready var name_sprite: Sprite2D = $NameSprite
@onready var color_rect: ColorRect = $ColorRect

@export var base_sprite_offset_value: float = 1
@export var name_sprite_offset_value: float = 1

func _physics_process(_delta: float) -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	base_sprite.global_position.x = screen_size.x * (base_sprite_offset_value + 1) / 2
	base_sprite.global_position.y = screen_size.y / 2
	
	name_sprite.global_position.x = screen_size.x * (name_sprite_offset_value + 1) / 2
	name_sprite.global_position.y = screen_size.y / 2
	
	color_rect.global_position = Vector2.ZERO
	color_rect.size = screen_size
	
	var scale_factor: float = 1 / 300.0 * screen_size.x
	base_sprite.scale = Vector2.ONE * scale_factor
	name_sprite.scale = Vector2.ONE * scale_factor
