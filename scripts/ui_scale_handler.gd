extends Node

@onready var parent: UI

func _ready() -> void:
	parent = get_parent()

func _physics_process(_delta: float) -> void:
	parent.location_popup.global_position = get_viewport().get_visible_rect().size / 2 + Vector2(0, parent.popup_value * -100 - 80)
	parent.location_popup.self_modulate.a = sin(parent.popup_value * PI)
	
	parent.accuracy_bar.global_position.x = get_viewport().get_visible_rect().size.x - 85
	parent.bullet_bar.global_position.x = get_viewport().get_visible_rect().size.x - 85 * parent.scale_float - 86
	
	parent.shooting_tutorial.global_position = get_viewport().get_visible_rect().size - Vector2(140, 70) * parent.scale_float
	parent.shooting_tutorial_label.global_position.y = get_viewport().get_visible_rect().size.y - parent.shooting_tutorial_label.size.y - 20
	parent.shooting_tutorial_label.size.x = 300 * parent.scale_float / 4
	parent.shooting_tutorial_label.add_theme_font_size_override("font_size", int(8 * parent.scale_float))
	
	parent.margin_container.set_deferred("size", get_viewport().get_visible_rect().size / parent.margin_container.scale)
	parent.margin_container.set_deferred("position", Vector2.ZERO)
