extends CanvasLayer

@onready var sub_viewport: SubViewport = $SubViewport

func _ready() -> void:
	SignalBus.scale_changed.connect(update_scale)

func _physics_process(_delta: float) -> void:
	sub_viewport.size = get_viewport().get_visible_rect().size / scale

func update_scale() -> void:
	scale = Vector2i.ONE * (Global.scale_level + 4)
