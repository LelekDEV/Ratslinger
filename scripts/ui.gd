extends CanvasLayer

@onready var hearts: HBoxContainer = $Hearts

func _ready() -> void:
	hearts.scale = Vector2i.ONE * 4
	hearts.global_position = Vector2i.ZERO

func update_hearts(health: float) -> void:
	var i: int = 0
	
	var hearts_sorted: Array = hearts.get_children()
	hearts_sorted.reverse()
	
	for heart: Control in hearts_sorted:
		heart.target_fill = clamp((health + (i - 1) * 4) / 4, 0, 1)
		i += 1

func update_hearts_old(health: int) -> void:
	var i: int = 0
	
	var hearts_sorted: Array = hearts.get_children()
	hearts_sorted.reverse()
	
	for heart: Sprite2D in hearts_sorted:
		heart.frame = clamp(8 - health - i * 4, 0, 4)
		i += 1
